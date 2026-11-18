import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lanh_app/features/meal_logging/data/http_meal_analysis_repository.dart';
import 'package:lanh_app/features/meal_logging/domain/meal_analysis.dart';

final _base = Uri.parse('http://192.168.1.10:8080/');

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test(
    'sends a trimmed description as the text field, without an image',
    () async {
      late http.Request sent;
      final repository = HttpMealAnalysisRepository(
        baseUri: _base,
        client: () => MockClient((request) async {
          sent = request;
          return _json({
            'data': {
              'items': [
                {
                  'id': 'pho-bo',
                  'name': 'Phở bò tái',
                  'portion': {'amount': 1, 'unit': 'serving'},
                  'nutrition': {'calories_kcal': 450},
                },
              ],
            },
            'meta': {'request_id': 'voice-1'},
          }, 200);
        }),
      );

      final result = await repository.analyzeText(
        '  Ăn một tô phở bò tái  ',
        requestId: 'voice-1',
      );

      expect(sent.url.path, '/v1/meal-analysis');
      expect(sent.headers['X-Request-ID'], 'voice-1');
      final body = utf8.decode(sent.bodyBytes);
      expect(body, contains('name="text"'));
      expect(body, contains('Ăn một tô phở bò tái\r\n'));
      expect(body, contains('name="request_id"'));
      expect(body, isNot(contains('name="image"')));
      expect(result.items.single.name, 'Phở bò tái');
      expect(result.totalCalories(), 450);
    },
  );

  test('maps food_not_identified for text to noFood', () async {
    final repository = HttpMealAnalysisRepository(
      baseUri: _base,
      client: () =>
          MockClient((_) async => _json({'code': 'food_not_identified'}, 422)),
    );
    await expectLater(
      repository.analyzeText('hôm nay trời đẹp', requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (f) => f.kind,
          'kind',
          MealAnalysisFailureKind.noFood,
        ),
      ),
    );
  });

  test('reports a missing base URL without calling the network', () async {
    var called = false;
    final repository = HttpMealAnalysisRepository(
      baseUri: null,
      client: () => MockClient((_) async {
        called = true;
        return http.Response('', 200);
      }),
    );
    await expectLater(
      repository.analyzeText('phở', requestId: 'r'),
      throwsA(
        isA<MealAnalysisFailure>().having(
          (f) => f.kind,
          'kind',
          MealAnalysisFailureKind.notConfigured,
        ),
      ),
    );
    expect(called, isFalse);
  });

  test('rejects empty or overlong descriptions before sending', () async {
    final repository = HttpMealAnalysisRepository(
      baseUri: _base,
      client: () => MockClient((_) async => http.Response('', 200)),
    );
    await expectLater(
      repository.analyzeText('   ', requestId: 'r'),
      throwsArgumentError,
    );
    await expectLater(
      repository.analyzeText(
        'a' * (HttpMealAnalysisRepository.maxDescriptionLength + 1),
        requestId: 'r',
      ),
      throwsArgumentError,
    );
  });
}
