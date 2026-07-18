import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/onboarding/onboarding_provider.dart';
import '../../l10n/app_localizations.dart';
import '../services/location_city_service.dart';

/// Runs GPS + reverse-geocoding city detection, surfacing a localized snackbar
/// on failure. Returns null (and shows the message) when it can't determine a
/// city — the caller then keeps the manual flow.
Future<GeoCityMatch?> detectCity(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    final villes = await ref.read(villesTourquieProvider.future);
    return await LocationCityService.detect(villes.provinces);
  } on LocationCityException catch (e) {
    // Permission permanently denied → send the user to app settings.
    if (e.error == LocationCityError.permissionDeniedForever) {
      if (context.mounted) _snack(context, l10n.locationOpenSettings);
      await Geolocator.openAppSettings();
      return null;
    }
    final msg = switch (e.error) {
      LocationCityError.serviceDisabled => l10n.locationServiceOff,
      LocationCityError.permissionDenied => l10n.locationPermissionDenied,
      LocationCityError.notFound => l10n.cityNotDetected,
      LocationCityError.geocodeFailed => l10n.cityNotDetected,
      LocationCityError.permissionDeniedForever => l10n.locationOpenSettings,
    };
    if (context.mounted) _snack(context, msg);
    return null;
  } catch (_) {
    if (context.mounted) _snack(context, l10n.locationError);
    return null;
  }
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
  );
}

/// A "📍 Use my location" button that runs [detectCity] and reports the result.
class LocationDetectButton extends ConsumerStatefulWidget {
  final void Function(GeoCityMatch match) onDetected;
  final Color foreground;

  const LocationDetectButton({
    super.key,
    required this.onDetected,
    this.foreground = Colors.white,
  });

  @override
  ConsumerState<LocationDetectButton> createState() =>
      _LocationDetectButtonState();
}

class _LocationDetectButtonState extends ConsumerState<LocationDetectButton> {
  bool _loading = false;

  Future<void> _run() async {
    if (_loading) return;
    setState(() => _loading = true);
    final match = await detectCity(context, ref);
    if (!mounted) return;
    setState(() => _loading = false);
    if (match != null) widget.onDetected(match);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fg = widget.foreground;

    return GestureDetector(
      onTap: _run,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: fg.withValues(alpha: 0.30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else
              Icon(Icons.my_location_rounded, size: 18, color: fg),
            const SizedBox(width: 10),
            Text(
              _loading ? l10n.locating : l10n.useMyLocation,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
