import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/localized_names.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_provider.dart';
import 'widgets/day_detail_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;
  // Anchor: current month = page 500 (allows 500 months back/forward)
  static const int _initialPage = 500;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _pageToMonth(int page) {
    final base = DateTime.now();
    final offset = page - _initialPage;
    return DateTime(base.year, base.month + offset);
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = _pageToMonth(_currentPage);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _CalendarHeader(
                  selectedMonth: selectedMonth,
                  onBack: canPop ? () => Navigator.pop(context) : null,
                  onPrev: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  },
                  onNext: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    child: GlassCard(
                      radius: 24,
                      blur: 16,
                      borderColor: Colors.white.withValues(alpha: 0.16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          _WeekdayHeaders(),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                                ref
                                    .read(selectedMonthProvider.notifier)
                                    .state = _pageToMonth(page);
                              },
                              itemBuilder: (_, page) {
                                final month = _pageToMonth(page);
                                return _MonthGrid(selectedMonth: month);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback? onBack;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final monthName = localizedMonth(lang, selectedMonth.month);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onBack,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                    ),
                    label: Text(
                      '',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              Text(
                AppLocalizations.of(context).calendar.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 48), // Placeholder for back button space
            ],
          ),
        ).animate().slideY(
          begin: -0.3,
          duration: 400.ms,
          curve: Curves.easeOut,
        ),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: onPrev,
                ),
                Text(
                  '$monthName ${selectedMonth.year}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: onNext,
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Weekday headers ────────────────────────────────────────────────────────────

class _WeekdayHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    // 1 = Monday … 7 = Sunday (5 = Friday, highlighted)
    final weekdays = [1, 2, 3, 4, 5, 6, 7];
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: weekdays
            .map(
              (wd) => Expanded(
                child: Center(
                  child: Text(
                    localizedWeekdayShort(lang, wd),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: wd == 5
                          ? AppTheme.accentOrange
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Month grid ─────────────────────────────────────────────────────────────────

class _MonthGrid extends ConsumerWidget {
  final DateTime selectedMonth;

  const _MonthGrid({required this.selectedMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horaires = ref.watch(calendarDataProvider);

    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      0,
    ).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    final Map<int, HorairesJourModel> byDay = {};
    for (final h in horaires) {
      final parts = h.date.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final mo = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y == selectedMonth.year && mo == selectedMonth.month && d != null) {
          byDay[d] = h;
        }
      }
    }

    final today = DateTime.now();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
      ),
      itemCount: rows * 7,
      itemBuilder: (ctx, index) {
        final dayNumber = index - startOffset + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final isToday =
            today.year == selectedMonth.year &&
            today.month == selectedMonth.month &&
            today.day == dayNumber;

        final horairesDay = byDay[dayNumber];

        return _DayCell(
              day: dayNumber,
              isToday: isToday,
              hasData: horairesDay != null,
              onTap: horairesDay != null
                  ? () => _showDetail(context, horairesDay)
                  : null,
            )
            .animate(delay: (30 * (index % 7)).ms)
            .fadeIn(duration: 250.ms)
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  void _showDetail(BuildContext context, HorairesJourModel horaires) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.darkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DayDetailSheet(horaires: horaires),
    );
  }
}

// ── Day cell ───────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool hasData;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isToday ? AppTheme.accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: hasData && !isToday
              ? Border.all(color: Colors.white.withValues(alpha: 0.2))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
            if (hasData && !isToday) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
