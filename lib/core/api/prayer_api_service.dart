import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exceptions.dart';

class PrayerApiService {
  static const String _baseUrl =
      'https://api-diyanet-horaires.vercel.app/api/horaires/mensuel';

  final Dio _dio;

  PrayerApiService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  Future<List<Map<String, dynamic>>> fetchMonthlyPrayers(
      String villeId) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'ville': villeId},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['success'] == true && data['horaires'] != null) {
          return (data['horaires'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        throw const BadRequestException('Réponse API invalide');
      }

      throw ServerException(
          response.statusCode ?? 500, 'Erreur HTTP ${response.statusCode}');
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const ApiTimeoutException();
        case DioExceptionType.connectionError:
          throw const NetworkException();
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode ?? 500;
          if (code == 400) throw const BadRequestException();
          if (code == 503) throw const DiyanetStructureException();
          throw ServerException(code);
        default:
          throw NetworkException(e.message ?? 'Erreur réseau inconnue');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }
}

final prayerApiServiceProvider = Provider<PrayerApiService>(
  (ref) => PrayerApiService(),
);
