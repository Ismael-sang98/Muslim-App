import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/api/api_exceptions.dart';
import '../../core/api/hadith_api_service.dart';
import '../../core/config/hadith_editions.dart';
import '../../core/hive/hive_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import 'hadith_detail_screen.dart';
import 'hadith_provider.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Read-only: mirror whatever the caller set on the provider before push.
    _searchController = TextEditingController(
      text: ref.read(hadithSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColl = ref.watch(selectedHadithCollectionProvider);
    final showFavorites = ref.watch(hadithShowFavoritesProvider);
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _HadithHeader(canPop: canPop),
                _SearchBar(controller: _searchController),
                if (!showFavorites) _CollectionChips(selected: selectedColl),
                Expanded(
                  child: showFavorites ? _FavoritesBody() : _EditionBody(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page header ────────────────────────────────────────────────────────────────

class _HadithHeader extends ConsumerWidget {
  final bool canPop;
  const _HadithHeader({required this.canPop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFavorites = ref.watch(hadithShowFavoritesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canPop)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 48),
          Text(
            AppLocalizations.of(context).hadith.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: AppLocalizations.of(context).fontSize,
                icon: const Icon(
                  Icons.format_size_rounded,
                  color: Colors.white,
                ),
                onPressed: () => _openFontSizeSheet(context, ref),
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).favorites,
                icon: Icon(
                  showFavorites
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: showFavorites ? AppTheme.accentOrange : Colors.white,
                ),
                onPressed: () =>
                    ref.read(hadithShowFavoritesProvider.notifier).state =
                        !showFavorites,
              ),
            ],
          ),
        ],
      ),
    );
  }

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
}

// ── Search bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends ConsumerWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(hadithSearchProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        cursorColor: AppTheme.primaryGreen,
        onChanged: (v) => ref.read(hadithSearchProvider.notifier).state = v,
        decoration: InputDecoration(
          isDense: true,
          hintText: AppLocalizations.of(context).hadithSearchHint,
          hintStyle: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.white38,
            size: 20,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    ref.read(hadithSearchProvider.notifier).state = '';
                  },
                ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.07),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ── Collection chips ───────────────────────────────────────────────────────────

class _CollectionChips extends ConsumerWidget {
  final String selected;
  const _CollectionChips({required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider).hadithLangue;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: hadithCollections.length,
        itemBuilder: (_, i) {
          final coll = hadithCollections[i];
          final isSelected = coll == selected;
          // null in the current language → will fall back to English
          final unavailable = editionFor(lang, coll) == null;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  ref.read(selectedHadithCollectionProvider.notifier).state =
                      coll,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text(
                      hadithCollectionNames[coll] ?? coll,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(
                                alpha: unavailable ? 0.40 : 0.65,
                              ),
                      ),
                    ),
                    if (unavailable) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'EN',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Search matching ──────────────────────────────────────────────────────────────

/// Matches a hadith against [query]: text substring, or exact number when
/// the query is numeric.
bool _matchesQuery(String text, int number, String query) {
  if (text.toLowerCase().contains(query)) return true;
  final n = int.tryParse(query);
  return n != null && number == n;
}

// ── Edition body (loading / error / list) ────────────────────────────────────────

class _EditionBody extends ConsumerWidget {
  const _EditionBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadithAsync = ref.watch(hadithDataProvider);
    final query = ref.watch(hadithSearchProvider).trim().toLowerCase();
    final coll = ref.watch(selectedHadithCollectionProvider);
    final lastRead = ref.watch(hadithProgressProvider)[coll];

    return hadithAsync.when(
      loading: () => const _SkeletonList(),
      error: (err, _) => _ErrorView(error: err),
      data: (result) {
        final data = result.data;
        // Skip phantom entries whose text is empty
        final all = data.hadiths
            .where((h) => h.text.trim().isNotEmpty)
            .toList();
        final filtered = query.isEmpty
            ? all
            : all.where((h) => _matchesQuery(h.text, h.number, query)).toList();
        final browsing = query.isEmpty;
        final hasSections = data.sections.isNotEmpty;

        void openDetail(int fullIndex) {
          if (fullIndex < 0) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HadithDetailScreen(
                hadiths: all,
                sections: data.sections,
                initialIndex: fullIndex,
                collection: coll,
                collectionName: data.collectionName,
                edition: result.edition,
              ),
            ),
          );
        }

        // Interleave chapter headers when browsing (not when searching).
        final rows = <_Row>[];
        if (browsing && hasSections) {
          int? currentSection;
          for (final h in filtered) {
            final sec = data.sectionFor(h.number);
            if (sec != null && sec.number != currentSection) {
              currentSection = sec.number;
              rows.add(_Row.header(sec.name));
            }
            rows.add(_Row.hadith(h));
          }
        } else {
          rows.addAll(filtered.map(_Row.hadith));
        }

        final resumeIndex = lastRead == null
            ? -1
            : all.indexWhere((h) => h.number == lastRead);

        void openChapters() {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppTheme.darkGreen,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => _ChaptersSheet(
              sections: data.sections,
              onSelect: (section) {
                Navigator.pop(context);
                openDetail(
                  all.indexWhere((h) => h.number >= section.firstHadith),
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryGreen,
          backgroundColor: AppTheme.darkGreen,
          onRefresh: () async {
            // Bypass cache so a fresh copy (with chapters) is downloaded.
            await HiveService.hadithCacheBox.delete(result.edition);
            ref.invalidate(hadithDataProvider);
            await ref.read(hadithDataProvider.future);
          },
          child: Column(
            children: [
              if (result.usedFallback)
                _FallbackBadge(collectionName: data.collectionName),
              if (browsing && resumeIndex >= 0)
                _ResumeBanner(
                  number: lastRead!,
                  onTap: () => openDetail(resumeIndex),
                ),
              _CountStrip(
                count: filtered.length,
                total: all.length,
                trailing: (browsing && hasSections)
                    ? _ChaptersButton(onTap: openChapters)
                    : null,
              ),
              Expanded(
                child: rows.isEmpty
                    ? const _EmptyResult()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                        itemCount: rows.length,
                        itemBuilder: (_, i) {
                          final row = rows[i];
                          if (row.header != null) {
                            return _ChapterHeader(name: row.header!);
                          }
                          final h = row.hadith!;
                          return _HadithCard(
                            item: h,
                            edition: result.edition,
                            collectionName: data.collectionName,
                            // Show chapter on card only in search mode
                            // (headers already group them when browsing).
                            sectionName: browsing
                                ? null
                                : data.sectionFor(h.number)?.name,
                            onOpen: () => openDetail(
                              all.indexWhere((x) => x.number == h.number),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── List row (header or hadith) ──────────────────────────────────────────────────

class _Row {
  final String? header;
  final HadithItem? hadith;
  const _Row.header(this.header) : hadith = null;
  const _Row.hadith(this.hadith) : header = null;
}

// ── Chapter header ───────────────────────────────────────────────────────────────

class _ChapterHeader extends StatelessWidget {
  final String name;
  const _ChapterHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chapters button + sheet ──────────────────────────────────────────────────────

class _ChaptersButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChaptersButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 14,
            color: AppTheme.lightGreen,
          ),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context).chapters,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChaptersSheet extends StatelessWidget {
  final List<HadithSection> sections;
  final void Function(HadithSection) onSelect;

  const _ChaptersSheet({required this.sections, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppLocalizations.of(context).chapters,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: sections.length,
              itemBuilder: (_, i) {
                final s = sections[i];
                return ListTile(
                  dense: true,
                  leading: Text(
                    '${s.number}',
                    style: GoogleFonts.poppins(
                      color: AppTheme.lightGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  title: Text(
                    s.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '#${s.firstHadith}–${s.lastHadith}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => onSelect(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resume banner ────────────────────────────────────────────────────────────────

class _ResumeBanner extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const _ResumeBanner({required this.number, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.bookmark_rounded,
                  color: AppTheme.primaryGreen,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).resumeReadingAt(number),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.primaryGreen,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Favorites body ───────────────────────────────────────────────────────────────

class _FavoritesBody extends ConsumerWidget {
  const _FavoritesBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(hadithFavoritesProvider);
    final query = ref.watch(hadithSearchProvider).trim().toLowerCase();

    final filtered = query.isEmpty
        ? favorites
        : favorites
              .where((f) => _matchesQuery(f.text, f.number, query))
              .toList();

    if (favorites.isEmpty) {
      return const _EmptyFavorites();
    }
    if (filtered.isEmpty) {
      return const _EmptyResult();
    }

    final items = filtered.map((f) => f.toItem()).toList();

    return Column(
      children: [
        _CountStrip(count: filtered.length, total: favorites.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final fav = filtered[i];
              return _HadithCard(
                item: fav.toItem(),
                edition: fav.edition,
                collectionName: fav.collectionName,
                onOpen: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HadithDetailScreen(
                      hadiths: items,
                      initialIndex: i,
                      collection: '',
                      collectionName: fav.collectionName,
                      edition: fav.edition,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Count strip ──────────────────────────────────────────────────────────────────

class _CountStrip extends StatelessWidget {
  final int count;
  final int total;
  final Widget? trailing;
  const _CountStrip({required this.count, required this.total, this.trailing});

  @override
  Widget build(BuildContext context) {
    final unit = AppLocalizations.of(context).hadithsLabel;
    final label = count == total ? '$total $unit' : '$count / $total $unit';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

// ── Hadith card ────────────────────────────────────────────────────────────────

class _HadithCard extends ConsumerWidget {
  final HadithItem item;
  final String edition;
  final String collectionName;
  final String? sectionName;
  final VoidCallback onOpen;

  const _HadithCard({
    required this.item,
    required this.edition,
    required this.collectionName,
    required this.onOpen,
    this.sectionName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSize = ref.watch(hadithFontSizeProvider);
    final isFav = ref.watch(
      hadithFavoritesProvider.select(
        (list) =>
            list.any((f) => f.edition == edition && f.number == item.number),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.number}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ),
                    if (item.grade.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(child: _GradeChip(grade: item.grade)),
                    ],
                    const Spacer(),
                    _CardAction(
                      icon: isFav
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: isFav ? AppTheme.accentOrange : Colors.white38,
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
                    _CardAction(
                      icon: Icons.copy_rounded,
                      color: Colors.white38,
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
                    _CardAction(
                      icon: Icons.share_rounded,
                      color: Colors.white38,
                      onTap: () => SharePlus.instance.share(
                        ShareParams(text: _shareText()),
                      ),
                    ),
                  ],
                ),
                if (sectionName != null && sectionName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 12,
                          color: AppTheme.lightGreen.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            sectionName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.lightGreen.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Text(
                    item.text,
                    textAlign: TextAlign.justify,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      height: 1.65,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _shareText() {
    final grade = item.grade.isNotEmpty ? ' (${item.grade})' : '';
    return '$collectionName #${item.number}$grade\n\n${item.text}';
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CardAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
      onPressed: onTap,
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String grade;
  const _GradeChip({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        grade,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppTheme.lightGreen,
        ),
      ),
    );
  }
}

// ── Skeleton loader ──────────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.08),
      highlightColor: Colors.white.withValues(alpha: 0.16),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ── Fallback badge ─────────────────────────────────────────────────────────────

class _FallbackBadge extends StatelessWidget {
  final String collectionName;
  const _FallbackBadge({required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.accentOrange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).collectionUnavailableInLang,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.accentOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty states ─────────────────────────────────────────────────────────────────

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, color: Colors.white38, size: 48),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context).noResults,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_border_rounded,
              color: Colors.white38,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).noFavoriteHadith,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).favoriteHadithHint,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────────

class _ErrorView extends ConsumerWidget {
  final Object error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final String message;
    if (error is ApiTimeoutException) {
      message = l10n.errorTimeout;
    } else if (error is NetworkException) {
      message = l10n.errorNoInternet;
    } else if (error is ServerException) {
      message = l10n.errorServer((error as ServerException).statusCode);
    } else {
      message = error.toString();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => ref.invalidate(hadithDataProvider),
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppTheme.primaryGreen,
              ),
              label: Text(
                l10n.retry,
                style: GoogleFonts.poppins(color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
