import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../domain/meal_analysis.dart';
import '../domain/meal_photo_repository.dart';
import 'meal_photo_upload.dart';

/// Calls the Lành meal API (`POST /v1/meal-analysis`, multipart).
///
/// Sends either an `image` file or a `text` description. Success bodies are `{data: {items}, meta}`; failures use RFC 9457
/// `application/problem+json` with a stable `code`. Photo bytes, descriptions
/// and response contents are never logged.
class HttpMealAnalysisRepository implements MealAnalysisRepository {
  HttpMealAnalysisRepository({
    required this._baseUri,
    http.Client Function()? client,
    this.timeout = const Duration(seconds: 90),
    Future<MealPhotoUpload> Function(MealPhoto)? prepareUpload,
  }) : _client = client ?? http.Client.new,
       _prepareUpload = prepareUpload ?? prepareMealPhotoUpload;

  final Uri? _baseUri;
  final http.Client Function() _client;
  final Future<MealPhotoUpload> Function(MealPhoto) _prepareUpload;
  final Duration timeout;

  /// Longest description the app sends; the voice screen enforces it too.
  static const maxDescriptionLength = 500;

  @override
  Future<MealAnalysis> analyzePhoto(
    MealPhoto photo, {
    required String requestId,
    Future<void>? cancel,
  }) async {
    final baseUri = _requireBaseUri();
    final MealPhotoUpload upload;
    try {
      upload = await _prepareUpload(photo);
    } catch (_) {
      throw const MealAnalysisFailure(MealAnalysisFailureKind.invalidPhoto);
    }
    return _send(
      baseUri,
      requestId: requestId,
      cancel: cancel,
      file: http.MultipartFile.fromBytes(
        'image',
        upload.bytes,
        filename: upload.fileName,
        contentType: MediaType.parse(upload.mimeType),
      ),
    );
  }

  @override
  Future<MealAnalysis> analyzeText(
    String description, {
    required String requestId,
    Future<void>? cancel,
  }) async {
    final text = description.trim();
    if (text.isEmpty || text.length > maxDescriptionLength) {
      throw ArgumentError.value(description, 'description');
    }
    return _send(
      _requireBaseUri(),
      requestId: requestId,
      cancel: cancel,
      text: text,
    );
  }

  Uri _requireBaseUri() =>
      _baseUri ??
      (throw const MealAnalysisFailure(MealAnalysisFailureKind.notConfigured));

  Future<MealAnalysis> _send(
    Uri baseUri, {
    required String requestId,
    Future<void>? cancel,
    http.MultipartFile? file,
    String? text,
  }) async {
    final abort = Completer<void>();
    var timedOut = false;
    final timer = Timer(timeout, () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    unawaited(
      cancel?.then((_) {
        if (!abort.isCompleted) abort.complete();
      }),
    );
    final request =
        http.AbortableMultipartRequest(
            'POST',
            baseUri.resolve('v1/meal-analysis'),
            abortTrigger: abort.future,
          )
          ..headers['Accept'] = 'application/json, application/problem+json'
          ..headers['X-Request-ID'] = requestId
          ..fields['request_id'] = requestId;
    if (text != null) request.fields['text'] = text;
    if (file != null) request.files.add(file);

    final client = _client();
    try {
      // abortTrigger closes the socket on real clients; racing the trigger
      // also bounds clients that ignore it.
      final response = await Future.any<http.Response>([
        client.send(request).then(http.Response.fromStream),
        abort.future.then<http.Response>(
          (_) => throw http.RequestAbortedException(request.url),
        ),
      ]);
      return _parse(response, requestId);
    } on http.RequestAbortedException {
      throw MealAnalysisFailure(
        timedOut
            ? MealAnalysisFailureKind.unavailable
            : MealAnalysisFailureKind.network,
      );
    } on http.ClientException {
      throw const MealAnalysisFailure(MealAnalysisFailureKind.network);
    } finally {
      timer.cancel();
      client.close();
    }
  }

  MealAnalysis _parse(http.Response response, String requestId) {
    final Object? body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw MealAnalysisFailure(_failureForStatus(response.statusCode));
    }
    if (response.statusCode != 200) {
      final code = body is Map ? body['code'] : null;
      throw MealAnalysisFailure(
        _failureForCode(code) ?? _failureForStatus(response.statusCode),
      );
    }
    final rawItems = switch (body) {
      {'data': {'items': final List<Object?> items}} => items,
      _ => throw const MealAnalysisFailure(MealAnalysisFailureKind.unexpected),
    };
    final items = rawItems.map(_item).nonNulls.toList();
    if (items.isEmpty) {
      throw const MealAnalysisFailure(MealAnalysisFailureKind.noFood);
    }
    final meta = body['meta'];
    final id = meta is Map && meta['request_id'] is String
        ? meta['request_id'] as String
        : requestId;
    return MealAnalysis(requestId: id, items: items);
  }

  /// Drops malformed components instead of failing the whole estimate.
  MealAnalysisItem? _item(Object? raw) {
    if (raw is! Map) return null;
    final name = raw['name'];
    if (name is! String || name.trim().isEmpty) return null;
    final id = raw['id'] is String ? raw['id'] as String : name;
    final nutrition = raw['nutrition'] is Map ? raw['nutrition'] as Map : {};
    return MealAnalysisItem(
      id: id,
      name: name.trim(),
      portion: _portion(raw['portion']),
      nutrition: MealNutrition(
        caloriesKcal: _number(nutrition['calories_kcal']),
        proteinGrams: _number(nutrition['protein_g']),
        carbohydrateGrams: _number(nutrition['carbohydrate_g']),
        fatGrams: _number(nutrition['fat_g']),
      ),
    );
  }

  MealPortion? _portion(Object? raw) {
    if (raw is! Map) return null;
    final amount = _number(raw['amount']);
    final unit = switch (raw['unit']) {
      'g' => MealPortionUnit.gram,
      'ml' => MealPortionUnit.milliliter,
      'serving' => MealPortionUnit.serving,
      'piece' => MealPortionUnit.piece,
      _ => null,
    };
    if (amount == null || amount <= 0 || unit == null) return null;
    return MealPortion(amount: amount, unit: unit);
  }

  double? _number(Object? raw) {
    if (raw is! num) return null;
    final value = raw.toDouble();
    return value.isFinite && value >= 0 ? value : null;
  }

  MealAnalysisFailureKind? _failureForCode(Object? code) => switch (code) {
    'food_not_identified' => MealAnalysisFailureKind.noFood,
    'invalid_image' ||
    'unsupported_image_type' ||
    'image_too_large' ||
    'input_required' => MealAnalysisFailureKind.invalidPhoto,
    'inference_timeout' ||
    'inference_unavailable' => MealAnalysisFailureKind.unavailable,
    'invalid_model_output' => MealAnalysisFailureKind.noFood,
    _ => null,
  };

  MealAnalysisFailureKind _failureForStatus(int status) => switch (status) {
    413 || 415 => MealAnalysisFailureKind.invalidPhoto,
    422 => MealAnalysisFailureKind.noFood,
    429 || >= 500 => MealAnalysisFailureKind.unavailable,
    _ => MealAnalysisFailureKind.unexpected,
  };
}
