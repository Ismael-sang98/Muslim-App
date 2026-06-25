import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/hijri_converter.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/services/update_service.dart';
import '../qibla/qibla_screen.dart';
import '../settings/settings_provider.dart';
import 'home_provider.dart';
import 'widgets/next_prayer_card.dart';
import 'widgets/prayer_list_tile.dart';
import 'widgets/countdown_timer_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) UpdateService.checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final villeId = ref.read(settingsProvider).villeId;
      ref.invalidate(nextPrayerProvider(villeId));
      ref.invalidate(currentPrayerProvider(villeId));
      ref.invalidate(exactAlarmGrantedProvider);
      _rescheduleNotifications(villeId);
    }
  }

  void _rescheduleNotifications(String villeId) {
    final prayerState = ref.read(prayerDataProvider(villeId));
    if (prayerState is PrayerDataLoaded) {
      final settings = ref.read(settingsProvider);
      NotificationService.scheduleMonthlyPrayers(
        horaires: prayerState.horaires,
        notificationsActives: settings.notificationsActives,
        minutesAvantRappel: settings.minutesAvantRappel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final villeId = settings.villeId;
    final prayerState = ref.watch(prayerDataProvider(villeId));

    return GradientScaffold(
      body: switch (prayerState) {
        PrayerDataLoading() => _buildShimmer(),
        PrayerDataError(:final message) => _buildError(
          context,
          message,
          villeId,
        ),
        PrayerDataLoaded(:final horaires) => _buildContent(
          context,
          horaires,
          villeId,
          settings,
        ),
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<HorairesJourModel> horaires,
    String villeId,
    dynamic settings,
  ) {
    final today = ref.watch(todayHorairesProvider(villeId));
    final nextPrayer = ref.watch(nextPrayerProvider(villeId));
    final currentPrayer = ref.watch(currentPrayerProvider(villeId));
    final prayerState = ref.watch(prayerDataProvider(villeId));
    final freshness = prayerState is PrayerDataLoaded
        ? prayerState.freshness
        : null;

    final exactAlarmGranted = ref.watch(exactAlarmGrantedProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // ── Bannière permission alarme exacte (Android 12 uniquement) ──────
          if (exactAlarmGranted is AsyncData<bool> &&
              exactAlarmGranted.value == false)
            _ExactAlarmBanner(onTap: () async {
              await NotificationService.requestExactAlarmPermission();
            }),

          // ── Dark green header ──────────────────────────────────────────────
          _HomeHeader(
            today: today,
            freshness: freshness,
            villeNom: settings.villeNom as String,
            onRefresh: () {
              HapticFeedback.lightImpact();
              ref.read(prayerDataProvider(villeId).notifier).refresh();
            },
          ),
          // ── Scrollable upper section + dark panel ──────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.read(prayerDataProvider(villeId).notifier).refresh(),
              color: AppTheme.accentOrange,
              backgroundColor: AppTheme.darkGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Location badge
                    if ((settings.villeNom as String).isNotEmpty)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD9D9D9,
                            ).withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            settings.villeNom as String,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    // Next prayer
                    if (nextPrayer != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: NextPrayerCard(nextPrayer: nextPrayer),
                      ),

                    // Countdown
                    const CountdownTimerWidget(),

                    const SizedBox(height: 10),

                    // ── Qibla button ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: _QiblaButton(),
                    ),

                    // ── Dark green prayer panel ────────────────────────────
                    if (today != null)
                      _PrayerListPanel(
                        today: today,
                        currentPrayer: currentPrayer,
                        nextPrayerKey: nextPrayer?.prayerKey,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.2),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _ShimmerBox(height: 80, width: double.infinity, radius: 32),
            const SizedBox(height: 16),
            const _ShimmerBox(height: 120, width: double.infinity, radius: 20),
            const SizedBox(height: 12),
            const _ShimmerBox(height: 42, width: 180, radius: 27),
            const SizedBox(height: 12),
            for (int i = 0; i < 6; i++) ...[
              const _ShimmerBox(height: 55, width: double.infinity, radius: 10),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message, String villeId) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(prayerDataProvider(villeId).notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dark green header ──────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final HorairesJourModel? today;
  final DataFreshness? freshness;
  final String villeNom;
  final VoidCallback onRefresh;

  const _HomeHeader({
    required this.today,
    required this.freshness,
    required this.villeNom,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')} ${_monthName(now.month)} ${now.year}';
    final hijriStr = today?.dateHijri.isNotEmpty == true
        ? today!.dateHijri
        : HijriConverter.toHijriString(now);

    //     final hijriStr = today?.dateHijri.isNotEmpty == true
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr.toLowerCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.lightGreen,
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
          if (freshness != null && freshness != DataFreshness.fresh)
            _FreshnessBadge(freshness: freshness!),
          Text(
            hijriStr,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOut);
  }

  String _monthName(int month) {
    const names = [
      '',
      'ocak',
      'şubat',
      'mart',
      'nisan',
      'mayıs',
      'haziran',
      'temmuz',
      'ağustos',
      'eylül',
      'ekim',
      'kasım',
      'aralık',
    ];
    return names[month];
  }
}

// ── Prayer list panel (dark green) ────────────────────────────────────────────

class _PrayerListPanel extends StatelessWidget {
  final HorairesJourModel today;
  final String? currentPrayer;
  final String? nextPrayerKey;

  const _PrayerListPanel({
    required this.today,
    required this.currentPrayer,
    required this.nextPrayerKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.darkGreen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Diğer vaktiler',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...HorairesJourModel.prayerKeys.asMap().entries.map((e) {
            final i = e.key;
            final key = e.value;
            return PrayerListTile(
                  prayerKey: key,
                  time: today.timeForPrayer(key),
                  isActive: currentPrayer == key,
                  isNext: nextPrayerKey == key,
                )
                .animate(delay: (50 * i).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2);
          }),

          // Mosque silhouette at bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

// ── Freshness badge ────────────────────────────────────────────────────────────

class _FreshnessBadge extends StatelessWidget {
  final DataFreshness freshness;
  const _FreshnessBadge({required this.freshness});

  @override
  Widget build(BuildContext context) {
    final isStale = freshness == DataFreshness.stale;
    return Container(
      margin: const EdgeInsets.only(right: 4, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isStale
            ? Colors.orange.withValues(alpha: 0.9)
            : Colors.grey.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isStale ? Icons.warning_amber : Icons.wifi_off,
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            isStale ? 'Eski' : 'Çevrimdışı',
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ── Bannière permission alarme exacte ─────────────────────────────────────────

class _ExactAlarmBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ExactAlarmBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFB45309),
          child: Row(
            children: [
              const Icon(Icons.alarm_off, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Notifications exactes désactivées — Appuyer pour activer',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Qibla button ──────────────────────────────────────────────────────────────

class _QiblaButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QiblaScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.explore, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kıble Yönü',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Kabe\'nin yönünü bul',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    required this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
