import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
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

    return GradientScaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CalendarHeader(
              selectedMonth: selectedMonth,
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
            const SizedBox(height: 4),
            _WeekdayHeaders(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  // Keep provider in sync for cache fetches
                  ref.read(selectedMonthProvider.notifier).state = _pageToMonth(
                    page,
                  );
                },
                itemBuilder: (_, page) {
                  final month = _pageToMonth(page);
                  return _MonthGrid(selectedMonth: month);
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _CalendarHeader extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = _monthName(selectedMonth.month);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: onPrev,
          ),
          Text(
            '$monthName ${selectedMonth.year}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
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
    ).animate().slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOut);
  }

  String _monthName(int month) {
    const names = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return names[month];
  }
}

// ── Weekday headers ────────────────────────────────────────────────────────────

class _WeekdayHeaders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Container(
      color: Colors.black.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: days
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: d == 'Cum'
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
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
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
