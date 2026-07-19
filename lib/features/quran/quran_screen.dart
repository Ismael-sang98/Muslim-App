import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../l10n/app_localizations.dart';
import 'quran_provider.dart';
import 'surah_screen.dart';
import 'favorites_screen.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _showJuz = false;

  // Surah de départ pour chaque Juz (index 0 = Juz 1)
  static const List<int> _juzStartSurah = [
    1,
    2,
    2,
    3,
    4,
    4,
    5,
    6,
    7,
    8,
    9,
    11,
    12,
    15,
    17,
    18,
    21,
    23,
    25,
    27,
    29,
    33,
    36,
    39,
    41,
    46,
    51,
    58,
    67,
    78,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _query.trim().length >= 2;
    final lastRead = ref.watch(lastReadProvider);

    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Floated header (no opaque band)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).quran,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.star_rounded,
                          color: AppTheme.accentOrange,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar (glass)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: GlassCard(
                    radius: 13,
                    blur: 16,
                    borderColor: Colors.white.withValues(alpha: 0.14),
                    padding: EdgeInsets.zero,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).quranSearchHint,
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white38,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        filled: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                // Toggle Sureler / Cüz (hidden when searching)
                if (!isSearching)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _ViewToggle(
                      showJuz: _showJuz,
                      onToggle: (v) => setState(() => _showJuz = v),
                    ),
                  ),

                // Reprendre card (visible when not searching and lastRead exists)
                if (!isSearching && lastRead != null)
                  _Reprendre(lastRead: lastRead),

                // Content
                Expanded(
                  child: isSearching
                      ? _SearchResults(query: _query.trim())
                      : _showJuz
                      ? _JuzGrid(juzStartSurah: _juzStartSurah)
                      : _ChapterList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── View toggle ───────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final bool showJuz;
  final ValueChanged<bool> onToggle;

  const _ViewToggle({required this.showJuz, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      blur: 14,
      borderColor: Colors.white.withValues(alpha: 0.12),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleChip(
            label: AppLocalizations.of(context).surahs,
            selected: !showJuz,
            onTap: () => onToggle(false),
          ),
          _ToggleChip(
            label: AppLocalizations.of(context).juz,
            selected: showJuz,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}

// ── Reprendre card ────────────────────────────────────────────────────────────

class _Reprendre extends ConsumerWidget {
  final Map<String, dynamic> lastRead;
  const _Reprendre({required this.lastRead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahName = lastRead['surahName'] as String? ?? '';
    final surahId = lastRead['surahId'] as int? ?? 1;
    final verseIndex = lastRead['verseIndex'] as int? ?? 0;
    final chaptersAsync = ref.watch(chaptersProvider);

    return chaptersAsync.maybeWhen(
      data: (chapters) {
        final chapter = chapters.firstWhere(
          (c) => (c['id'] as int) == surahId,
          orElse: () => <String, dynamic>{},
        );
        if (chapter.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurahScreen(
                chapter: chapter,
                targetVerseNumber: verseIndex + 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: GlassCard(
              radius: 14,
              blur: 16,
              borderColor: AppTheme.primaryGreen.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.lightGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).continueReading,
                          style: GoogleFonts.poppins(
                            color: AppTheme.lightGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$surahName · Ayet ${verseIndex + 1}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.lightGreen,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ── Juz grid ──────────────────────────────────────────────────────────────────

class _JuzGrid extends ConsumerWidget {
  final List<int> juzStartSurah;
  const _JuzGrid({required this.juzStartSurah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);

    return chaptersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
      error: (_, _) => _ErrorView(
        message: AppLocalizations.of(context).connectionError,
        onRetry: () => ref.invalidate(chaptersProvider),
      ),
      data: (chapters) {
        final chapterMap = {for (final c in chapters) c['id'] as int: c};
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: 30,
          itemBuilder: (context, i) {
            final juzNum = i + 1;
            final surahId = juzStartSurah[i];
            final chapter = chapterMap[surahId];
            final surahName = chapter?['name_simple'] as String? ?? '';

            return GestureDetector(
              onTap: chapter != null
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahScreen(chapter: chapter),
                      ),
                    )
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$juzNum',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.lightGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${AppLocalizations.of(context).juz} $juzNum',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white38,
                      ),
                    ),
                    Text(
                      surahName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Chapter list ──────────────────────────────────────────────────────────────

class _ChapterList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    return chaptersAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
      error: (e, _) => _ErrorView(
        message: AppLocalizations.of(context).connectionErrorCheckInternet,
        onRetry: () => ref.invalidate(chaptersProvider),
      ),
      data: (chapters) => ListView.builder(
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          return _ChapterTile(chapter: chapters[index]);
        },
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Map<String, dynamic> chapter;

  const _ChapterTile({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final id = chapter['id'] as int? ?? 0;
    final nameArabic = chapter['name_arabic'] as String? ?? '';
    final nameSimple = chapter['name_simple'] as String? ?? '';
    final versesCount = chapter['verses_count'] as int? ?? 0;
    final translatedName =
        (chapter['translated_name'] as Map?)?['name'] as String? ?? '';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SurahScreen(chapter: chapter)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Center(
                child: Text(
                  '$id',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppTheme.lightGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameSimple,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (translatedName.isNotEmpty)
                    Text(
                      translatedName,
                      style: GoogleFonts.poppins(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  nameArabic,
                  style: const TextStyle(
                    fontFamily: 'Lateef',
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
                Text(
                  '$versesCount ayet',
                  style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  List<Map<String, dynamic>> _filterChapters(
    List<Map<String, dynamic>> chapters,
    String q,
  ) {
    final lq = q.toLowerCase();
    return chapters.where((c) {
      final nameSimple = (c['name_simple'] as String? ?? '').toLowerCase();
      final nameArabic = c['name_arabic'] as String? ?? '';
      final translated =
          ((c['translated_name'] as Map?)?['name'] as String? ?? '')
              .toLowerCase();
      return nameSimple.contains(lq) ||
          nameArabic.contains(q) ||
          translated.contains(lq);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(chaptersProvider);
    final versesAsync = ref.watch(quranSearchProvider(query));

    // Detect direct verse navigation: "2:255"
    final directMatch = RegExp(r'^(\d+):(\d+)$').firstMatch(query.trim());
    Map<String, dynamic>? directChapter;
    int directVerseNumber = 1;
    if (directMatch != null) {
      final surahId = int.tryParse(directMatch.group(1)!);
      directVerseNumber = int.tryParse(directMatch.group(2)!) ?? 1;
      chaptersAsync.whenData((chapters) {
        if (surahId != null && surahId >= 1 && surahId <= 114) {
          directChapter = chapters.firstWhere(
            (c) => (c['id'] as int) == surahId,
            orElse: () => <String, dynamic>{},
          );
          if ((directChapter as Map).isEmpty) directChapter = null;
        }
      });
    }

    final matchingSurahs = chaptersAsync.maybeWhen(
      data: (c) => _filterChapters(c, query),
      orElse: () => <Map<String, dynamic>>[],
    );

    final versesLoading = versesAsync.isLoading;
    final verses = versesAsync.maybeWhen(
      data: (v) => v,
      orElse: () => <Map<String, dynamic>>[],
    );

    if (!versesLoading &&
        directChapter == null &&
        matchingSurahs.isEmpty &&
        verses.isEmpty) {
      return Center(
        child: Text(
          '"$query" için sonuç bulunamadı.',
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Direct verse navigation card
        if (directChapter != null)
          _DirectVerseCard(
            chapter: directChapter!,
            verseNumber: directVerseNumber,
          ),

        // Surah matches
        if (matchingSurahs.isNotEmpty) ...[
          _SectionHeader(
            label: AppLocalizations.of(context).surahs,
            count: matchingSurahs.length,
          ),
          ...matchingSurahs.map((c) => _ChapterTile(chapter: c)),
          const SizedBox(height: 8),
        ],

        // Verse matches
        if (directChapter == null) ...[
          _SectionHeader(
            label: AppLocalizations.of(context).verses,
            count: versesLoading ? null : verses.length,
          ),
          if (versesLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              ),
            )
          else if (verses.isEmpty && matchingSurahs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                AppLocalizations.of(context).noVerseResults,
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
              ),
            )
          else
            ...verses.map((r) => _SearchResultTile(result: r)),
        ],
      ],
    );
  }
}

// ── Direct verse card ─────────────────────────────────────────────────────────

class _DirectVerseCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final int verseNumber;

  const _DirectVerseCard({required this.chapter, required this.verseNumber});

  @override
  Widget build(BuildContext context) {
    final nameSimple = chapter['name_simple'] as String? ?? '';
    final versesCount = chapter['verses_count'] as int? ?? 286;
    final safeVerse = verseNumber.clamp(1, versesCount);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SurahScreen(chapter: chapter, targetVerseNumber: safeVerse),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: GlassCard(
          radius: 14,
          blur: 16,
          borderColor: AppTheme.accentOrange.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.my_location_rounded,
                color: AppTheme.accentOrange,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).goDirectly,
                      style: GoogleFonts.poppins(
                        color: AppTheme.accentOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$nameSimple · Ayet $safeVerse',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.accentOrange,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final int? count;
  const _SectionHeader({required this.label, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightGreen,
              letterSpacing: 1.2,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppTheme.lightGreen,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultTile extends ConsumerWidget {
  final Map<String, dynamic> result;
  const _SearchResultTile({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(selectedQuranLanguageProvider);
    final verseKey = result['verse_key'] as String? ?? '';
    final text = translationText(result, lang);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              verseKey,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppTheme.lightGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).retry,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
