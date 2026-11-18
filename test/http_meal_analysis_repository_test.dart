import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/data/meal_photo_upload.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_photo_repository.dart';
import 'package:lanh_app/features/meal_logging/meal_logging_providers.dart';

final _jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);
final _photo = MealPhoto(_jpeg);
final _base = Uri.parse('http://192.168.1.10:8080/');

HttpMealAnalysisRepository _repository(
  MockClientHandler handler, {
  Duration timeout = const Duration(seconds: 90),
}) => HttpMealAnalysisRepository(
  baseUri: _base,
  client: () => MockClient(handler),
  timeout: timeout,
);

http.Response _json(Object body, int status, {bool problem = false}) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {
        'content-type': problem
            ? 'application/problem+json'
            : 'application/json; charset=utf-8',
      },
    );

void main() {
  test('sends the photo as multipart with a stable request id', () async {
    late http.Request sent;
    final repository = _repository((request) async {
      sent = request;
      return _json({
        'data': {
          'items': [
            {
              'id': 'pho-bo',
              'name': 'Phở bò',
              'portion': {'amount': 400, 'unit': 'g'},
              'nutrition': {
                'calories_kcal': 520,
                'protein_g': 28,
                'carbohydrate_g': 68,
                'fat_g': null,
              },
            },
            {'name': '  ', 'nutrition': {}},
            {
              'name': 'Trà đá',
              'portion': {'amount': 0, 'unit': 'cup'},
              'nutrition': {'calories_kcal': -1},
            },
          ],
        },
        'meta': {'request_id': 'req-1', 'schema_version': '1'},
      }, 200);
    });

    final result = await repository.analyzePhoto(_photo, requestId: 'req-1');

    expect(sent.method, 'POST');
    expect(sent.url.toString(), 'http://192.168.1.10:8080/v1/meal-analysis');
    expect(sent.headers['X-Request-ID'], 'req-1');
    final body = latin1.decode(sent.bodyBytes);
    expect(body, contains('name="request_id"'));
    expect(body, contains('name="image"; filename="meal.jpeg"'));
    expect(body, contains('content-type: image/jpeg'));
    expect(result.requestId, 'req-1');
    expect(result.items, hasLength(2));
    final pho = result.items.first;
    expect(pho.name, 'Phở bò');
    expect(pho.portion!.amount, 400);
    expect(pho.portion!.unit, MealPortionUnit.gram);
    expect(pho.nutrition.caloriesKcal, 520);
    expect(pho.nutrition.fatGrams, isNull);
    final tea = result.items.last;
    expect(tea.portion, isNull);
    expect(tea.nutrition.caloriesKcal, isNull);
    expect(result.totalCalories(), 520);
    expect(result.itemsMissingCalories, 1);
  });

  for (final (status, code, kind) in [
    (422, 'food_not_identified', MealAnalysisFailureKind.noFood),
    (415, 'unsupported_image_type', MealAnalysisFailureKind.invalidPhoto),
    (413, 'image_too_large', MealAnalysisFailureKind.invalidPhoto),
    (504, 'inference_timeout', MealAnalysisFailureKind.unavailable),
    (503, 'inference_unavailable', MealAnalysisFailureKind.unavailable),
    (500, 'internal_error', MealAnalysisFailureKind.unavailable),
  ]) {
    test('maps problem $code to ${kind.name}', () async {
      final repository = _repository(
        (_) async => _json(
          {
            'type': 'https://api.lanh.app/problems/$code',
            'status': status,
            'code': code,
          },
          status,
          problem: true,
        ),
      );
      await expectLater(
        repository.analyzePhoto(_photo, requestId: 'r'),
        throwsA(isA<MealAnalysisFailure>().having((e) => e.kind, 'kind', kind)),
      );
    });
  }

  test('an empty item list means no food was found', () async {
    final repository = _repository(
      (_) async => _json({
        'data': {'items': <Object>[]},
      }, 200),
    );
    await expectLater(
      repository.analyzePhoto(_photo, requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (e) => e.kind,
          'kind',
          MealAnalysisFailureKind.noFood,
        ),
      ),
    );
  });

  test('unexpected success body and network failures are typed', () async {
    await expectLater(
      _repository((_) async => _json({'items': []}, 200))
          .analyzePhoto(_photo, requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (e) => e.kind,
          'kind',
          MealAnalysisFailureKind.unexpected,
        ),
      ),
    );
    await expectLater(
      _repository((_) async => throw http.ClientException('offline'))
          .analyzePhoto(_photo, requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (e) => e.kind,
          'kind',
          MealAnalysisFailureKind.network,
        ),
      ),
    );
  });

  test('a slow server times out as unavailable', () async {
    final repository = _repository(
      (_) => Completer<http.Response>().future,
      timeout: const Duration(milliseconds: 20),
    );
    await expectLater(
      repository.analyzePhoto(_photo, requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (e) => e.kind,
          'kind',
          MealAnalysisFailureKind.unavailable,
        ),
      ),
    );
  });

  test('a build without a base URL reports notConfigured', () async {
    await expectLater(
      HttpMealAnalysisRepository(baseUri: null)
          .analyzePhoto(_photo, requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (e) => e.kind,
          'kind',
          MealAnalysisFailureKind.notConfigured,
        ),
      ),
    );
  });

  test('base URL accepts a host with or without a trailing slash', () {
    expect(mealApiBaseUri(''), isNull);
    expect(mealApiBaseUri('not a url'), isNull);
    expect(
      mealApiBaseUri('http://10.0.0.2:8080').toString(),
      'http://10.0.0.2:8080/',
    );
    expect(
      mealApiBaseUri('https://api.lanh.app/meal/').toString(),
      'https://api.lanh.app/meal/',
    );
  });

  test('supported formats pass through unchanged', () async {
    final upload = await prepareMealPhotoUpload(_photo);
    expect(upload.mimeType, 'image/jpeg');
    expect(upload.bytes, same(_jpeg));
  });

  test('domain rejects invalid quantities', () {
    expect(
      () => MealPortion(amount: 0, unit: MealPortionUnit.gram),
      throwsArgumentError,
    );
    expect(
      () => MealPortion(amount: double.nan, unit: MealPortionUnit.gram),
      throwsArgumentError,
    );
    expect(() => MealNutrition(caloriesKcal: -1), throwsArgumentError);
    expect(
      () => MealAnalysis(requestId: 'r', items: const []),
      throwsArgumentError,
    );
  });
}
