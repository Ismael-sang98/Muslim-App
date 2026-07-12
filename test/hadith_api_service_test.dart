import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:namaz_vakti/core/api/api_exceptions.dart';
import 'package:namaz_vakti/core/api/hadith_api_service.dart';
import 'package:namaz_vakti/core/config/hadith_editions.dart';

// ── Mock ───────────────────────────────────────────────────────────────────────

class MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────────────

const _base =
    'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

Map<String, dynamic> _fakePayload(String name) => {
      'metadata': {'name': name},
      'hadiths': [
        {'hadithnumber': 1, 'text': 'Hadith one'},
        {'hadithnumber': 2, 'text': 'Hadith two'},
      ],
    };

Response<dynamic> _response(Map<String, dynamic> body) => Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: body,
    );

DioException _dioError(
  DioExceptionType type, {
  int? statusCode,
  RequestOptions? opts,
}) =>
    DioException(
      requestOptions: opts ?? RequestOptions(path: ''),
      type: type,
      response: statusCode != null
          ? Response(
              requestOptions: opts ?? RequestOptions(path: ''),
              statusCode: statusCode,
            )
          : null,
    );

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  late MockDio mockDio;
  late HadithApiService service;

  setUp(() {
    mockDio = MockDio();
    service = HadithApiService(mockDio);
    registerFallbackValue(Options());
  });

  group('HadithApiService.fetchEdition', () {
    test('1 — .min.json disponible → retourne HadithEditionData', () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenAnswer((_) async => _response(_fakePayload('Sahih al-Bukhari')));

      final result = await service.fetchEdition('eng-bukhari');

      expect(result.collectionName, 'Sahih al-Bukhari');
      expect(result.hadiths.length, 2);
      expect(result.hadiths.first.number, 1);
      expect(result.hadiths.first.text, 'Hadith one');
    });

    test('1b — parse le grade depuis le champ grades de l\'API', () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenAnswer(
        (_) async => _response({
          'metadata': {'name': 'Sahih al-Bukhari'},
          'hadiths': [
            {
              'hadithnumber': 1,
              'text': 'Hadith one',
              'grades': [
                {'name': 'Al-Albani', 'grade': 'Sahih'},
              ],
            },
            {'hadithnumber': 2, 'text': 'Hadith two'},
          ],
        }),
      );

      final result = await service.fetchEdition('eng-bukhari');

      expect(result.hadiths.first.grade, 'Sahih');
      expect(result.hadiths[1].grade, ''); // absent → vide
    });

    test('1c — parse les chapitres (sections + section_details)', () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenAnswer(
        (_) async => _response({
          'metadata': {
            'name': 'Sahih al-Bukhari',
            'sections': {'0': '', '1': 'Revelation', '2': 'Belief'},
            'section_details': {
              '0': {'hadithnumber_first': null, 'hadithnumber_last': null},
              '1': {'hadithnumber_first': 1, 'hadithnumber_last': 7},
              '2': {'hadithnumber_first': 8, 'hadithnumber_last': 58},
            },
          },
          'hadiths': [
            {'hadithnumber': 3, 'text': 'A'},
            {'hadithnumber': 10, 'text': 'B'},
          ],
        }),
      );

      final result = await service.fetchEdition('eng-bukhari');

      // Empty-name section (0) is skipped; two real chapters remain.
      expect(result.sections.length, 2);
      expect(result.sections.first.name, 'Revelation');
      expect(result.sectionFor(3)?.name, 'Revelation');
      expect(result.sectionFor(10)?.name, 'Belief');
      expect(result.sectionFor(999), isNull);
    });

    test('2 — .min.json → 404, .json disponible → fallback réussi', () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenThrow(_dioError(DioExceptionType.badResponse, statusCode: 404));

      when(
        () => mockDio.get('$_base/eng-bukhari.json'),
      ).thenAnswer((_) async => _response(_fakePayload('Sahih al-Bukhari')));

      final result = await service.fetchEdition('eng-bukhari');

      expect(result.collectionName, 'Sahih al-Bukhari');
      expect(result.hadiths.length, 2);
    });

    test('3 — timeout réseau → lance ApiTimeoutException', () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenThrow(_dioError(DioExceptionType.connectionTimeout));

      expect(
        () => service.fetchEdition('eng-bukhari'),
        throwsA(isA<ApiTimeoutException>()),
      );
    });

    test('4 — pas de réseau → lance NetworkException', () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenThrow(_dioError(DioExceptionType.connectionError));

      expect(
        () => service.fetchEdition('eng-bukhari'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('5 — JSON malformé (String invalide) → lance CacheException',
        () async {
      when(
        () => mockDio.get('$_base/eng-bukhari.min.json'),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 200,
          data: 'not-json-at-all',
        ),
      );

      expect(
        () => service.fetchEdition('eng-bukhari'),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('editionFor — collections indisponibles', () {
    test('6 — editionFor("tr","qudsi") == null (indisponible en turc)',
        () {
      expect(editionFor('tr', 'qudsi'), isNull);
    });

    test('6b — editionFor("en","qudsi") != null (disponible en anglais)',
        () {
      expect(editionFor('en', 'qudsi'), isNotNull);
      expect(editionFor('en', 'qudsi'), 'eng-qudsi');
    });
  });
}
