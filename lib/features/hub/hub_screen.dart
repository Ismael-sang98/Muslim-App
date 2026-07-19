import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/localized_names.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/calendar_screen.dart';
import '../hadith/hadith_provider.dart';
import '../hadith/hadith_screen.dart';

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = [
      _HubEntry(
        icon: Icons.calendar_month_rounded,
        color: AppTheme.accentOrange,
        title: l10n.calendar,
        subtitle: l10n.calendarSubtitle,
        destination: const CalendarScreen(),
      ),
      _HubEntry(
        icon: Icons.auto_stories_rounded,
        color: AppTheme.lightGreen,
        title: l10n.hadith,
        subtitle: l10n.hadithSubtitle,
        destination: const HadithScreen(),
      ),
    ];

    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(),
                  const SizedBox(height: 28),
                  ...entries.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _HubCard(entry: e.value)
                          .animate(delay: (120 + 90 * e.key).ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: 0.14,
                            duration: 400.ms,
                            curve: Curves.easeOut,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const _DailyHadithCard()
                      .animate(delay: 320.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(
                        begin: 0.14,
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hadith of the day ────────────────────────────────────────────────────────────

class _DailyHadithCard extends ConsumerWidget {
  const _DailyHadithCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(hadithOfTheDayProvider);

    return async.when(
      loading: () => Shimmer.fromColors(
        baseColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.16),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (daily) {
        if (daily == null) return const SizedBox.shrink();
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              ref.read(selectedHadithCollectionProvider.notifier).state =
                  'bukhari';
              ref.read(hadithShowFavoritesProvider.notifier).state = false;
              // Set the filter before pushing so the page opens on this hadith.
              ref.read(hadithSearchProvider.notifier).state = daily.item.number
                  .toString();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HadithScreen()),
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: GlassCard(
              radius: 22,
              blur: 10,
              fillOpacity: 0,
              borderColor: Colors.white.withValues(alpha: 0.16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).hadithOfTheDay,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppTheme.accentOrange.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    daily.item.text,
                    maxLines: 4,
                    textAlign: TextAlign.justify,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      height: 1.6,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${daily.collectionName} · #${daily.item.number}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).readMore,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightGreen,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppTheme.lightGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final dateStr =
        '${now.day} ${localizedMonth(lang, now.month)} ${now.year} · ${localizedWeekdayFull(lang, now.weekday)}';

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.explore,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 6),
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.08, duration: 400.ms, curve: Curves.easeOut);
  }
}

// ── Hub entry model ────────────────────────────────────────────────────────────

class _HubEntry {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget destination;

  const _HubEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.destination,
  });
}

// ── Hub card ───────────────────────────────────────────────────────────────────

class _HubCard extends ConsumerWidget {
  final _HubEntry entry;
  const _HubCard({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Reset any lingering hadith search before opening a section.
          ref.read(hadithSearchProvider.notifier).state = '';
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => entry.destination),
          );
        },
        borderRadius: BorderRadius.circular(22),
        child: GlassCard(
          radius: 22,
          blur: 16,
          borderColor: entry.color.withValues(alpha: 0.40),
          child: Stack(
            children: [
              // Decorative watermark
              Positioned(
                right: -18,
                bottom: -22,
                child: Icon(
                  entry.icon,
                  size: 130,
                  color: entry.color.withValues(alpha: 0.10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: entry.color.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: entry.color.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(entry.icon, color: entry.color, size: 30),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: GoogleFonts.poppins(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.60),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: entry.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: entry.color,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
