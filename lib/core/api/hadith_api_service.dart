import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exceptions.dart';

// ── Data models ───────────────────────────────────────────────────────────────

class HadithItem {
  final int number;
  final String text;
  final String grade;

  const HadithItem({
    required this.number,
    required this.text,
    this.grade = '',
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) => HadithItem(
        number: (json['hadithnumber'] as num).toInt(),
        text: _sanitize(json['text'] as String? ?? ''),
        // 'grades' = raw API list, 'grade' = our flattened cache value
        grade: _extractGrade(json['grades'] ?? json['grade']),
      );

  Map<String, dynamic> toJson() => {
        'hadithnumber': number,
        'text': text,
        if (grade.isNotEmpty) 'grade': grade,
      };
}

/// Extracts a single authenticity grade from the API `grades` field.
/// The cache stores it flattened as a `grade` string, so both shapes
/// (raw API list of {name, grade} + our flattened string) are handled.
String _extractGrade(dynamic raw) {
  if (raw is String) return _sanitize(raw);
  if (raw is List) {
    for (final g in raw) {
      if (g is Map && g['grade'] is String) {
        final value = _sanitize(g['grade'] as String);
        if (value.isNotEmpty) return value;
      }
    }
  }
  return '';
}

/// A chapter/book ("kitâb") grouping a contiguous range of hadith numbers.
class HadithSection {
  final int number;
  final String name;
  final int firstHadith;
  final int lastHadith;

  const HadithSection({
    required this.number,
    required this.name,
    required this.firstHadith,
    required this.lastHadith,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': name,
        'first': firstHadith,
        'last': lastHadith,
      };

  factory HadithSection.fromJson(Map<String, dynamic> json) => HadithSection(
        number: _asInt(json['number']) ?? 0,
        name: json['name'] as String? ?? '',
        firstHadith: _asInt(json['first']) ?? 0,
        lastHadith: _asInt(json['last']) ?? 0,
      );
}

class HadithEditionData {
  final String collectionName;
  final List<HadithItem> hadiths;
  final List<HadithSection> sections;

  const HadithEditionData({
    required this.collectionName,
    required this.hadiths,
    this.sections = const [],
  });

  factory HadithEditionData.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>? ?? {};
    final name = meta['name'] as String? ?? '';
    final rawList = json['hadiths'] as List? ?? [];
    return HadithEditionData(
      collectionName: name,
      hadiths: rawList
          .map((e) => HadithItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      sections: _parseSections(json, meta),
    );
  }

  /// Returns the chapter containing [hadithNumber], or null.
  HadithSection? sectionFor(int hadithNumber) {
    for (final s in sections) {
      if (hadithNumber >= s.firstHadith && hadithNumber <= s.lastHadith) {
        return s;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'metadata': {'name': collectionName},
        'sections': sections.map((s) => s.toJson()).toList(),
        'hadiths': hadiths.map((h) => h.toJson()).toList(),
      };
}

/// Parses chapters from either the raw API shape
/// (`metadata.sections` + `metadata.section_details`) or our flattened
/// cache shape (top-level `sections` list).
List<HadithSection> _parseSections(
  Map<String, dynamic> json,
  Map<String, dynamic> meta,
) {
  // Cache format: flat list.
  final cached = json['sections'];
  if (cached is List) {
    return cached
        .whereType<Map>()
        .map((e) => HadithSection.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // API format: names map + details map.
  final names = meta['sections'];
  final details = meta['section_details'];
  if (names is Map && details is Map) {
    final list = <HadithSection>[];
    names.forEach((key, value) {
      final name = (value as String?)?.trim() ?? '';
      final det = details[key];
      if (name.isEmpty || det is! Map) return;
      final first = _asInt(det['hadithnumber_first']);
      final last = _asInt(det['hadithnumber_last']);
      if (first == null || last == null) return;
      list.add(HadithSection(
        number: _asInt(key) ?? 0,
        name: name,
        firstHadith: first,
        lastHadith: last,
      ));
    });
    list.sort((a, b) => a.firstHadith.compareTo(b.firstHadith));
    return list;
  }
  return const [];
}

int? _asInt(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

// ── Sanitization ──────────────────────────────────────────────────────────────

String _sanitize(String raw) {
  // Strip HTML tags
  var text = raw.replaceAll(RegExp(r'<[^>]*>'), '');
  // Collapse whitespace
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return text;
}

// ── Service ───────────────────────────────────────────────────────────────────

class HadithApiService {
  static const _base =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  final Dio _dio;

  HadithApiService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  /// Fetches [edition], tries `.min.json` first, falls back to `.json`.
  Future<HadithEditionData> fetchEdition(String edition) async {
    try {
      final response = await _getWithFallback(edition);
      final data = response.data;
      final map = data is String
          ? Map<String, dynamic>.from(jsonDecode(data) as Map)
          : Map<String, dynamic>.from(data as Map);
      final result = HadithEditionData.fromJson(map);
      debugPrint('[Hadith] Fetch success: $edition (${result.hadiths.length} hadiths)');
      return result;
    } on ApiException catch (e) {
      debugPrint('[Hadith] Error [${e.runtimeType}]: ${e.message}');
      rethrow;
    } on FormatException catch (e) {
      debugPrint('[Hadith] Error [FormatException]: ${e.message}');
      throw CacheException('JSON malformé : ${e.message}');
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      debugPrint('[Hadith] Error [unexpected]: $e');
      throw CacheException('Erreur inattendue : $e');
    }
  }

  Future<Response<dynamic>> _getWithFallback(String edition) async {
    debugPrint('[Hadith] Fetching $edition.min.json...');
    try {
      return await _dio.get('$_base/$edition.min.json');
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      if (e.type == DioExceptionType.badResponse &&
          (status == 404 || status >= 500)) {
        debugPrint('[Hadith] .min.json → $status, retrying with .json');
        return await _dio.get('$_base/$edition.json');
      }
      rethrow;
    }
  }

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        debugPrint('[Hadith] Error [timeout]: ${e.type}');
        throw const ApiTimeoutException();
      case DioExceptionType.connectionError:
        debugPrint('[Hadith] Error [connectionError]: ${e.message}');
        throw const NetworkException();
      case DioExceptionType.badResponse:
        debugPrint('[Hadith] Error [${e.response?.statusCode}]: ${e.message}');
        throw ServerException(e.response?.statusCode ?? 500);
      default:
        debugPrint('[Hadith] Error [${e.type}]: ${e.message}');
        throw NetworkException(e.message ?? 'Erreur réseau');
    }
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

final hadithApiServiceProvider = Provider<HadithApiService>(
  (_) => HadithApiService(),
);
