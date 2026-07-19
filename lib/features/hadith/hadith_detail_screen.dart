import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/api/hadith_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'hadith_provider.dart';

class HadithDetailScreen extends ConsumerStatefulWidget {
  final List<HadithItem> hadiths;
  final List<HadithSection> sections;
  final int initialIndex;
  final String collection;
  final String collectionName;
  final String edition;

  const HadithDetailScreen({
    super.key,
    required this.hadiths,
    required this.initialIndex,
    required this.collection,
    required this.collectionName,
    required this.edition,
    this.sections = const [],
  });

  String? _sectionNameFor(int number) {
    for (final s in sections) {
      if (number >= s.firstHadith && number <= s.lastHadith) return s.name;
    }
    return null;
  }

  @override
  ConsumerState<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends ConsumerState<HadithDetailScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    // Provider writes are forbidden during initState → defer to post-frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveProgress());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _saveProgress() {
    if (!mounted || widget.collection.isEmpty) return;
    ref
        .read(hadithProgressProvider.notifier)
        .setLastRead(widget.collection, widget.hadiths[_currentIndex].number);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailHeader(
              collectionName: widget.collectionName,
              position: _currentIndex + 1,
              total: widget.hadiths.length,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.hadiths.length,
                onPageChanged: (i) {
                  setState(() => _currentIndex = i);
                  _saveProgress();
                },
                itemBuilder: (_, i) => _DetailPage(
                  item: widget.hadiths[i],
                  edition: widget.edition,
                  collectionName: widget.collectionName,
                  sectionName: widget._sectionNameFor(widget.hadiths[i].number),
                ),
              ),
            ),
            _DetailNavBar(
              hasPrev: _currentIndex > 0,
              hasNext: _currentIndex < widget.hadiths.length - 1,
              onPrev: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              onNext: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
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

class _DetailHeader extends StatelessWidget {
  final String collectionName;
  final int position;
  final int total;

  const _DetailHeader({
    required this.collectionName,
    required this.position,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              collectionName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$position / $total',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page ───────────────────────────────────────────────────────────────────────

class _DetailPage extends ConsumerWidget {
  final HadithItem item;
  final String edition;
  final String collectionName;
  final String? sectionName;

  const _DetailPage({
    required this.item,
    required this.edition,
    required this.collectionName,
    this.sectionName,
  });

  void _openFontSizeSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).fontSize,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (_, r, _) {
                final size = r.watch(hadithFontSizeProvider);
                return Row(
                  children: [
                    const Text(
                      'A',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    Expanded(
                      child: Slider(
                        value: size,
                        min: 12,
                        max: 22,
                        divisions: 10,
                        activeColor: AppTheme.primaryGreen,
                        label: size.round().toString(),
                        onChanged: (v) =>
                            r.read(hadithFontSizeProvider.notifier).state = v,
                      ),
                    ),
                    const Text(
                      'A',
                      style: TextStyle(color: Colors.white54, fontSize: 22),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(hadithFontSizeProvider);
    final isFav = ref.watch(
      hadithFavoritesProvider.select(
        (list) =>
            list.any((f) => f.edition == edition && f.number == item.number),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: GlassCard(
        radius: 22,
        blur: 18,
        borderColor: Colors.white.withValues(alpha: 0.16),
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.number}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Yazı boyutu',
                    icon: const Icon(
                      Icons.format_size_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => _openFontSizeSheet(context, ref),
                  ),
                ],
              ),
              if (item.grade.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.grade,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (sectionName != null && sectionName!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: AppTheme.accentOrange,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    sectionName!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SelectableText(
            item.text,
            textAlign: TextAlign.justify,
            style: GoogleFonts.poppins(
              fontSize: fontSize + 1,
              height: 1.7,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _ActionButton(
                icon: isFav ? Icons.star_rounded : Icons.star_border_rounded,
                label: isFav
                    ? AppLocalizations.of(context).favorited
                    : AppLocalizations.of(context).favorite,
                color: isFav ? AppTheme.accentOrange : Colors.white70,
                onTap: () => ref
                    .read(hadithFavoritesProvider.notifier)
                    .toggle(
                      HadithFavorite(
                        edition: edition,
                        collectionName: collectionName,
                        number: item.number,
                        text: item.text,
                        grade: item.grade,
                      ),
                    ),
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.copy_rounded,
                label: AppLocalizations.of(context).copy,
                color: Colors.white70,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _shareText()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).copied),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: Icons.share_rounded,
                label: AppLocalizations.of(context).share,
                color: Colors.white70,
                onTap: () =>
                    SharePlus.instance.share(ShareParams(text: _shareText())),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }

  String _shareText() {
    final grade = item.grade.isNotEmpty ? ' (${item.grade})' : '';
    return '$collectionName #${item.number}$grade\n\n${item.text}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 10, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom nav bar ───────────────────────────────────────────────────────────────

class _DetailNavBar extends StatelessWidget {
  final bool hasPrev;
  final bool hasNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DetailNavBar({
    required this.hasPrev,
    required this.hasNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              icon: Icons.chevron_left_rounded,
              label: AppLocalizations.of(context).previous,
              enabled: hasPrev,
              onTap: onPrev,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NavButton(
              icon: Icons.chevron_right_rounded,
              label: AppLocalizations.of(context).next,
              enabled: hasNext,
              onTap: onNext,
              trailingIcon: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool trailingIcon;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.trailingIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? Colors.white : Colors.white24;
    final children = <Widget>[
      Icon(icon, color: color, size: 22),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    ];

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primaryGreen.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? AppTheme.primaryGreen.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: trailingIcon ? children.reversed.toList() : children,
        ),
      ),
    );
  }
}
