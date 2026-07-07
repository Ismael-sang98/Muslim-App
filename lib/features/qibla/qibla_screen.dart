import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  _QiblaStatus _status = _QiblaStatus.loading;
  double _qiblaBearing = 0;
  double _heading = 0;
  bool _isAligned = false;
  bool _wasAligned = false;
  StreamSubscription<CompassEvent>? _compassSub;
  late final AnimationController _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _init();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _glowAnim.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (FlutterCompass.events == null) {
      setState(() => _status = _QiblaStatus.noSensor);
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() => _status = _QiblaStatus.permissionDenied);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _qiblaBearing = _calculateQibla(pos.latitude, pos.longitude);
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      _qiblaBearing = last != null
          ? _calculateQibla(last.latitude, last.longitude)
          : _calculateQibla(41.0082, 28.9784);
    }

    _compassSub = FlutterCompass.events!.listen((event) {
      if (!mounted || event.heading == null) return;
      final heading = event.heading!;
      final qiblaAngle = (_qiblaBearing - heading + 360) % 360;
      final aligned = qiblaAngle < 5 || qiblaAngle > 355;

      // Single haptic pulse on transition to aligned
      if (aligned && !_wasAligned) {
        HapticFeedback.mediumImpact();
      }
      _wasAligned = aligned;

      setState(() {
        _heading = heading;
        _isAligned = aligned;
      });
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
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF07120C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
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
      _QiblaStatus.loading => _buildLoading(),
      _QiblaStatus.permissionDenied => _buildError(
        icon: Icons.location_off_rounded,
        message:
            'Konum iznine ihtiyaç var.\nKıble yönünü hesaplamak için izin verin.',
        buttonLabel: 'İzin Ver',
        onTap: () async => Geolocator.openAppSettings(),
      ),
      _QiblaStatus.noSensor => _buildError(
        icon: Icons.sensors_off_rounded,
        message: 'Bu cihazda manyetometre sensörü bulunamadı.',
        buttonLabel: null,
        onTap: null,
      ),
      _QiblaStatus.ready => _buildCompass(),
    };
  }

  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.6,
          colors: [Color(0xFF112219), Color(0xFF07120C)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
    );
  }

  Widget _buildError({
    required IconData icon,
    required String message,
    required String? buttonLabel,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.6,
          colors: [Color(0xFF112219), Color(0xFF07120C)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.white38),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white60,
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
      ),
    );
  }

  Widget _buildCompass() {
    final rotation = -_heading * pi / 180;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [Color(0xFF112219), Color(0xFF07120C)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availH = constraints.maxHeight;
            // Scale compass to fit — max 320, min 180
            final compassSize = (availH * 0.45).clamp(180.0, 320.0);
            final gap = (availH * 0.05).clamp(8.0, 36.0);
            final glowExtra = compassSize * 0.06;

            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: availH),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Bearing display
                    _buildBearingDisplay(compact: compassSize < 260),

                    SizedBox(height: gap),

                    // Compass with glow
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, _) {
                        final pulse = _isAligned ? _glowAnim.value : 0.0;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring (animated)
                            if (_isAligned)
                              Container(
                                width: compassSize + glowExtra * 2 + 8 * pulse,
                                height: compassSize + glowExtra * 2 + 8 * pulse,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withValues(
                                        alpha: 0.15 + 0.20 * pulse,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 12,
                                    ),
                                  ],
                                ),
                              ),

                            // Compass disc
                            SizedBox(
                              width: compassSize,
                              height: compassSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: rotation,
                                    child: CustomPaint(
                                      size: Size(compassSize, compassSize),
                                      painter: _CompassPainter(
                                        qiblaBearing: _qiblaBearing,
                                        isAligned: _isAligned,
                                        glowValue: pulse,
                                      ),
                                    ),
                                  ),
                                  // Center pivot
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _isAligned
                                          ? AppTheme.primaryGreen
                                          : const Color(0xFFCCCCCC),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _isAligned
                                              ? AppTheme.primaryGreen
                                                  .withValues(alpha: 0.6)
                                              : Colors.black45,
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: gap),

                    // Status badge
                    _buildStatusBadge(),

                    SizedBox(height: gap * 0.35),
                    Text(
                      'Kabe • Mekke  21.42°N  39.82°E',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white24,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBearingDisplay({bool compact = false}) {
    return Column(
      children: [
        Text(
          '${_qiblaBearing.toStringAsFixed(1)}°',
          style: GoogleFonts.poppins(
            fontSize: compact ? 28 : 40,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'KABE YÖNİ',
          style: GoogleFonts.poppins(
            fontSize: compact ? 9 : 11,
            color: AppTheme.lightGreen,
            letterSpacing: 4,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
      decoration: BoxDecoration(
        color: _isAligned
            ? AppTheme.primaryGreen.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: _isAligned
              ? AppTheme.primaryGreen
              : Colors.white.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: _isAligned
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isAligned
                  ? Icons.check_circle_rounded
                  : Icons.screen_rotation_rounded,
              key: ValueKey(_isAligned),
              color: _isAligned ? AppTheme.lightGreen : Colors.white38,
              size: 19,
            ),
          ),
          const SizedBox(width: 9),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isAligned ? 'Kıbleye dönüyorsunuz' : 'Telefonu döndürün',
              key: ValueKey(_isAligned),
              style: GoogleFonts.poppins(
                color: _isAligned ? AppTheme.lightGreen : Colors.white38,
                fontSize: 15,
                fontWeight: _isAligned ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compass painter ───────────────────────────────────────────────────────────

class _CompassPainter extends CustomPainter {
  final double qiblaBearing;
  final bool isAligned;
  final double glowValue;

  const _CompassPainter({
    required this.qiblaBearing,
    required this.isAligned,
    required this.glowValue,
  });

  static const _kGreen = Color(0xFF2EA85D);
  static const _kGreenBright = Color(0xFF4CAF50);
  static const _kRed = Color(0xFFEF5350);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawBackground(canvas, center, radius);
    _drawRings(canvas, center, radius);
    _drawTicks(canvas, center, radius);
    _drawCardinalLabels(canvas, center, radius);
    _drawQiblaLine(canvas, center, radius);
    _drawNorthNeedle(canvas, center, radius * 0.40);
    _drawQiblaMarker(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    // Dark disc with subtle radial gradient
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF1C3828), const Color(0xFF0B1D12)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 1, paint);
  }

  void _drawRings(Canvas canvas, Offset center, double radius) {
    // Outer border
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Inner guide ring
    canvas.drawCircle(
      center,
      radius - 26,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 360; i += 5) {
      final angle = i * pi / 180 - pi / 2;
      final isMajor = i % 45 == 0;
      final isMid = i % 15 == 0;
      final len = isMajor
          ? 14.0
          : isMid
          ? 9.0
          : 5.0;
      final alpha = isMajor
          ? 0.85
          : isMid
          ? 0.55
          : 0.25;
      final sw = isMajor ? 2.0 : 1.2;

      final outer = radius - 3;
      final inner = outer - len;
      canvas.drawLine(
        center + Offset(cos(angle) * inner, sin(angle) * inner),
        center + Offset(cos(angle) * outer, sin(angle) * outer),
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawCardinalLabels(Canvas canvas, Offset center, double radius) {
    const labelR = 0.77; // fraction of radius
    _label(
      canvas,
      center,
      radius * labelR,
      'N',
      -pi / 2,
      _kRed,
      15,
      FontWeight.w800,
    );
    _label(
      canvas,
      center,
      radius * labelR,
      'S',
      pi / 2,
      Colors.white70,
      13,
      FontWeight.w600,
    );
    _label(
      canvas,
      center,
      radius * labelR,
      'E',
      0,
      Colors.white70,
      13,
      FontWeight.w600,
    );
    _label(
      canvas,
      center,
      radius * labelR,
      'W',
      pi,
      Colors.white70,
      13,
      FontWeight.w600,
    );
    _label(
      canvas,
      center,
      radius * 0.76,
      'NE',
      -pi / 4,
      Colors.white38,
      9,
      FontWeight.w500,
    );
    _label(
      canvas,
      center,
      radius * 0.76,
      'SE',
      pi / 4,
      Colors.white38,
      9,
      FontWeight.w500,
    );
    _label(
      canvas,
      center,
      radius * 0.76,
      'SW',
      3 * pi / 4,
      Colors.white38,
      9,
      FontWeight.w500,
    );
    _label(
      canvas,
      center,
      radius * 0.76,
      'NW',
      -3 * pi / 4,
      Colors.white38,
      9,
      FontWeight.w500,
    );
  }

  void _label(
    Canvas canvas,
    Offset center,
    double dist,
    String text,
    double angle,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final pos = center + Offset(cos(angle) * dist, sin(angle) * dist);
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawNorthNeedle(Canvas canvas, Offset center, double length) {
    const angle = -pi / 2;
    final tip = center + Offset(cos(angle) * length, sin(angle) * length);
    final tail =
        center + Offset(cos(angle + pi) * length, sin(angle + pi) * length);
    final lv = Offset(cos(angle + pi / 2) * 9, sin(angle + pi / 2) * 9);
    final rv = Offset(cos(angle - pi / 2) * 9, sin(angle - pi / 2) * 9);

    // Red north half
    final nPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(center.dx + lv.dx, center.dy + lv.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx + rv.dx, center.dy + rv.dy)
      ..close();
    canvas.drawPath(nPath, Paint()..color = _kRed);
    canvas.drawPath(
      nPath,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // White south half
    final sPath = Path()
      ..moveTo(tail.dx, tail.dy)
      ..lineTo(center.dx + lv.dx, center.dy + lv.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx + rv.dx, center.dy + rv.dy)
      ..close();
    canvas.drawPath(
      sPath,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  void _drawQiblaLine(Canvas canvas, Offset center, double radius) {
    final angle = qiblaBearing * pi / 180 - pi / 2;
    final endPos =
        center + Offset(cos(angle) * (radius - 28), sin(angle) * (radius - 28));

    // Subtle glow line
    canvas.drawLine(
      center,
      endPos,
      Paint()
        ..color = (isAligned ? _kGreenBright : _kGreen).withValues(alpha: 0.25)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    // Main line
    canvas.drawLine(
      center,
      endPos,
      Paint()
        ..color = (isAligned ? _kGreenBright : _kGreen).withValues(alpha: 0.80)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawQiblaMarker(Canvas canvas, Offset center, double radius) {
    final angle = qiblaBearing * pi / 180 - pi / 2;
    final markerPos =
        center + Offset(cos(angle) * (radius - 18), sin(angle) * (radius - 18));
    final green = isAligned ? _kGreenBright : _kGreen;

    // Outer glow (animated)
    if (isAligned) {
      canvas.drawCircle(
        markerPos,
        17 + 4 * glowValue,
        Paint()
          ..color = green.withValues(alpha: 0.15 + 0.15 * glowValue)
          ..style = PaintingStyle.fill,
      );
    }

    // Outer ring
    canvas.drawCircle(
      markerPos,
      15,
      Paint()
        ..color = green.withValues(alpha: isAligned ? 0.35 : 0.20)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      markerPos,
      15,
      Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Kaaba emoji
    final tp = TextPainter(
      text: const TextSpan(text: '🕋', style: TextStyle(fontSize: 15)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, markerPos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.qiblaBearing != qiblaBearing ||
      old.isAligned != isAligned ||
      old.glowValue != glowValue;
}
