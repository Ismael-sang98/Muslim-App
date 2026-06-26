import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/quran_config.dart';
import 'api_exceptions.dart';

class QuranApiService {
  final Dio _dio;

  QuranApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: QuranConfig.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'X-Auth-Token': QuranConfig.apiKey},
          ),
        );

  Future<List<Map<String, dynamic>>> fetchChapters() async {
    try {
      final response = await _dio.get('/chapters');
      final data = response.data as Map<String, dynamic>;
      return (data['chapters'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchVersesByChapter(int chapterId) async {
    try {
      final response = await _dio.get(
        '/verses/by_chapter/$chapterId',
        queryParameters: {
          'translations': '${QuranConfig.trId},${QuranConfig.frId},${QuranConfig.enId}',
          'fields': 'text_uthmani,verse_key',
          'per_page': 300,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return (data['verses'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> fetchRandomVerse() async {
    try {
      final response = await _dio.get(
        '/verses/random',
        queryParameters: {
          'translations': '${QuranConfig.trId},${QuranConfig.frId},${QuranConfig.enId}',
          'fields': 'text_uthmani,verse_key',
        },
      );
      final data = response.data as Map<String, dynamic>;
      return Map<String, dynamic>.from(data['verse'] as Map);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> search(String query, int translationId) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query,
          'size': 20,
          'translations': translationId,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final results = data['search']?['results'] as List? ?? [];
      return results
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw const ApiTimeoutException();
      case DioExceptionType.connectionError:
        throw const NetworkException();
      case DioExceptionType.badResponse:
        throw ServerException(e.response?.statusCode ?? 500);
      default:
        throw NetworkException(e.message ?? 'Erreur réseau');
    }
  }
}

final quranApiServiceProvider = Provider<QuranApiService>(
  (ref) => QuranApiService(),
);
