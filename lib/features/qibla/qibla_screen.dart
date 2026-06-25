import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

enum _QiblaStatus { loading, permissionDenied, noSensor, ready }

class _QiblaScreenState extends State<QiblaScreen> {
  _QiblaStatus _status = _QiblaStatus.loading;
  double _qiblaBearing = 0;
  double _heading = 0;
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    // 1. Check sensor availability
    if (FlutterCompass.events == null) {
      setState(() => _status = _QiblaStatus.noSensor);
      return;
    }

    // 2. Request location permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() => _status = _QiblaStatus.permissionDenied);
      return;
    }

    // 3. Get GPS position
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _qiblaBearing = _calculateQibla(pos.latitude, pos.longitude);
    } catch (_) {
      // Use last known or default (Istanbul) if GPS times out
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _qiblaBearing = _calculateQibla(last.latitude, last.longitude);
      } else {
        _qiblaBearing = _calculateQibla(41.0082, 28.9784); // Istanbul
      }
    }

    // 4. Subscribe to compass
    _compassSub = FlutterCompass.events!.listen((event) {
      if (mounted && event.heading != null) {
        setState(() => _heading = event.heading!);
      }
    });

    setState(() => _status = _QiblaStatus.ready);
  }

  double _calculateQibla(double lat, double lng) {
    const mLat = 21.4225 * pi / 180;
    const mLng = 39.8262 * pi / 180;
    final uLat = lat * pi / 180;
    final uLng = lng * pi / 180;
    final x = sin(mLng - uLng) * cos(mLat);
    final y = cos(uLat) * sin(mLat) - sin(uLat) * cos(mLat) * cos(mLng - uLng);
    return (atan2(x, y) * 180 / pi + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkGreen,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kıble',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return switch (_status) {
      _QiblaStatus.loading => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
      _QiblaStatus.permissionDenied => _buildError(
        icon: Icons.location_off,
        message:
            'Konum iznine ihtiyaç var.\nKıble yönünü hesaplamak için izin verin.',
        buttonLabel: 'İzin Ver',
        onTap: () async {
          await Geolocator.openAppSettings();
        },
      ),
      _QiblaStatus.noSensor => _buildError(
        icon: Icons.sensors_off,
        message: 'Bu cihazda manyetometre sensörü bulunamadı.',
        buttonLabel: null,
        onTap: null,
      ),
      _QiblaStatus.ready => _buildCompass(),
    };
  }

  Widget _buildError({
    required IconData icon,
    required String message,
    required String? buttonLabel,
    required VoidCallback? onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white54),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 15,
                height: 1.6,
              ),
            ),
            if (buttonLabel != null && onTap != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompass() {
    final rotation = -_heading * pi / 180;
    final qiblaAngle = (_qiblaBearing - _heading + 360) % 360;
    final isAligned = qiblaAngle < 5 || qiblaAngle > 355;

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_qiblaBearing.toStringAsFixed(1)}°',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white54,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kıble Yönü',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white54,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 32),

              // Compass rose
              SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: rotation,
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _CompassPainter(qiblaBearing: _qiblaBearing),
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isAligned ? AppTheme.primaryGreen : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isAligned
                      ? AppTheme.primaryGreen.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isAligned ? AppTheme.primaryGreen : Colors.white24,
                  ),
                ),
                child: Text(
                  isAligned ? '✓ Kıbleye dönüyorsunuz' : 'Telefonu döndürün',
                  style: GoogleFonts.poppins(
                    color: isAligned ? AppTheme.lightGreen : Colors.white54,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Text(
            'Kabe, Mekke — 21.4225°N 39.8262°E',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white30),
          ),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double qiblaBearing;

  const _CompassPainter({required this.qiblaBearing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer circle
    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius - 4,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Degree ticks
    final tickPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1;
    final majorTickPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;

    for (int i = 0; i < 360; i += 5) {
      final angle = i * pi / 180 - pi / 2;
      final isMajor = i % 45 == 0;
      final tickLen = isMajor ? 12.0 : 6.0;
      final inner = radius - 4 - tickLen;
      final outer = radius - 6.0;
      canvas.drawLine(
        center + Offset(cos(angle) * inner, sin(angle) * inner),
        center + Offset(cos(angle) * outer, sin(angle) * outer),
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    // Cardinal labels N/S/E/W
    _drawLabel(canvas, center, radius, 'N', -pi / 2, Colors.red.shade400);
    _drawLabel(canvas, center, radius, 'S', pi / 2, Colors.white70);
    _drawLabel(canvas, center, radius, 'E', 0, Colors.white70);
    _drawLabel(canvas, center, radius, 'W', pi, Colors.white70);

    // North arrow (red, pointing up = -pi/2)
    _drawArrow(
      canvas,
      center,
      radius * 0.38,
      -pi / 2,
      Colors.red.shade400,
      Colors.white24,
    );

    // Qibla indicator (Kaaba emoji replaced by green arrow + crescent)
    _drawQiblaIndicator(canvas, center, radius, qiblaBearing);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    double angle,
    Color color,
  ) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: textStyle.copyWith(color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final labelRadius = radius - 30;
    final offset =
        center +
        Offset(cos(angle) * labelRadius, sin(angle) * labelRadius) -
        Offset(tp.width / 2, tp.height / 2);
    tp.paint(canvas, offset);
  }

  void _drawArrow(
    Canvas canvas,
    Offset center,
    double length,
    double angle,
    Color tipColor,
    Color tailColor,
  ) {
    final tip = center + Offset(cos(angle) * length, sin(angle) * length);
    final tail =
        center + Offset(cos(angle + pi) * length, sin(angle + pi) * length);
    final left =
        center + Offset(cos(angle + pi / 2) * 8, sin(angle + pi / 2) * 8);
    final right =
        center + Offset(cos(angle - pi / 2) * 8, sin(angle - pi / 2) * 8);

    // Tip (red/colored)
    final tipPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(tipPath, Paint()..color = tipColor);

    // Tail (light)
    final tailPath = Path()
      ..moveTo(tail.dx, tail.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = tailColor);
  }

  void _drawQiblaIndicator(
    Canvas canvas,
    Offset center,
    double radius,
    double bearing,
  ) {
    final angle = bearing * pi / 180 - pi / 2;
    final indicatorRadius = radius - 24;
    final pos =
        center +
        Offset(cos(angle) * indicatorRadius, sin(angle) * indicatorRadius);

    // Green glow circle
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = const Color(0xFF2EA85D).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pos,
      14,
      Paint()
        ..color = const Color(0xFF2EA85D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Kaaba icon text
    final tp = TextPainter(
      text: const TextSpan(text: '🕋', style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));

    // Green line from center to indicator
    canvas.drawLine(
      center,
      pos - Offset(cos(angle) * 16, sin(angle) * 16),
      Paint()
        ..color = const Color(0xFF2EA85D).withValues(alpha: 0.5)
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.qiblaBearing != qiblaBearing;
}
