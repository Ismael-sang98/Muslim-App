import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../features/onboarding/onboarding_provider.dart';

enum LocationCityError {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  geocodeFailed,
  notFound,
}

class LocationCityException implements Exception {
  final LocationCityError error;
  const LocationCityException(this.error);
}

/// Result of an automatic city detection. [districtId] is null when only the
/// province could be matched (the user then picks the district).
class GeoCityMatch {
  final String provinceId;
  final String provinceNom;
  final String? districtId;
  final String? districtNom;

  const GeoCityMatch({
    required this.provinceId,
    required this.provinceNom,
    this.districtId,
    this.districtNom,
  });

  bool get hasDistrict => districtId != null;
}

/// Detects the user's Diyanet province/district from GPS, by reverse-geocoding
/// the position and matching the returned names against [provinces]
/// (villes_turquie.json). Matching is name-based (no coordinates in the data),
/// so it is best-effort — always let the user confirm/adjust.
class LocationCityService {
  static Future<GeoCityMatch> detect(List<Province> provinces) async {
    // Ask for permission FIRST so the system dialog shows even when the
    // device's location service happens to be off.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // Android won't show the dialog again → the UI opens app settings.
      throw const LocationCityException(
        LocationCityError.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const LocationCityException(LocationCityError.permissionDenied);
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationCityException(LocationCityError.serviceDisabled);
    }

    final Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (_) {
      throw const LocationCityException(LocationCityError.serviceDisabled);
    }

    final List<Placemark> marks;
    try {
      marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    } catch (_) {
      throw const LocationCityException(LocationCityError.geocodeFailed);
    }
    if (marks.isEmpty) {
      throw const LocationCityException(LocationCityError.notFound);
    }
    final pm = marks.first;

    final province = _matchProvince(provinces, pm.administrativeArea);
    if (province == null) {
      throw const LocationCityException(LocationCityError.notFound);
    }

    final district = _matchDistrict(province, [
      pm.subAdministrativeArea ?? '',
      pm.locality ?? '',
      pm.subLocality ?? '',
    ]);

    return GeoCityMatch(
      provinceId: province.id,
      provinceNom: province.nom,
      districtId: district?.id,
      districtNom: district?.nom,
    );
  }

  static Province? _matchProvince(List<Province> provinces, String? name) {
    final target = _norm(name ?? '');
    if (target.isEmpty) return null;
    for (final p in provinces) {
      if (_norm(p.nom) == target) return p;
    }
    // Loose fallback: one name contains the other.
    for (final p in provinces) {
      final np = _norm(p.nom);
      if (np.length >= 4 && (np.contains(target) || target.contains(np))) {
        return p;
      }
    }
    return null;
  }

  static District? _matchDistrict(Province province, List<String> candidates) {
    final normalized = {for (final d in province.districts) d: _norm(d.nom)};

    for (final raw in candidates) {
      final c = _norm(raw);
      if (c.isEmpty) continue;
      // Exact match first.
      for (final entry in normalized.entries) {
        if (entry.value == c) return entry.key;
      }
      // Then containment (guarded by length to avoid false positives).
      if (c.length >= 4) {
        for (final entry in normalized.entries) {
          if (entry.value.contains(c) || c.contains(entry.value)) {
            return entry.key;
          }
        }
      }
    }

    // City-centre fallback: a "(Merkez)" district.
    for (final d in province.districts) {
      if (d.nom.toLowerCase().contains('merkez')) return d;
    }
    return null;
  }

  /// Turkish-aware normalization: replace TR letters, lowercase, drop
  /// parentheses/punctuation → comparable ASCII key.
  static String _norm(String input) {
    var s = input;
    const replacements = {
      'ı': 'i', 'İ': 'i', 'ş': 's', 'Ş': 's', 'ğ': 'g', 'Ğ': 'g',
      'ç': 'c', 'Ç': 'c', 'ö': 'o', 'Ö': 'o', 'ü': 'u', 'Ü': 'u',
      'â': 'a', 'Â': 'a', 'î': 'i', 'Î': 'i', 'û': 'u', 'Û': 'u',
    };
    replacements.forEach((k, v) => s = s.replaceAll(k, v));
    s = s.toLowerCase();
    s = s.replaceAll(RegExp(r'\(.*?\)'), ' ');
    s = s.replaceAll(RegExp(r'[^a-z0-9]'), '');
    return s;
  }
}
