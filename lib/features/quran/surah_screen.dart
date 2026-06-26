import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/quran_colors.dart';
import 'quran_provider.dart';

class SurahScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> chapter;
  final int? targetVerseNumber;

  const SurahScreen({super.key, required this.chapter, this.targetVerseNumber});

  @override
  ConsumerState<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends ConsumerState<SurahScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _enterController;
  int _estimatedVerseIndex = 0;
  late final bool _showBismillah;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final chapterId = widget.chapter['id'] as int;
    _showBismillah = chapterId != 9;
    final surahName = widget.chapter['name_simple'] as String? ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(lastReadProvider.notifier)
          .save(surahId: chapterId, surahName: surahName, verseIndex: 0);
      _enterController.forward();

      if (widget.targetVerseNumber != null && widget.targetVerseNumber! > 1) {
        if (_scrollController.hasClients) {
          final bismillahOffset = _showBismillah ? 220.0 : 0.0;
          final offset =
              (widget.targetVerseNumber! - 1) * 220.0 + bismillahOffset;
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          );
        }
      }
    });

    _scrollController.addListener(() {
      final index = (_scrollController.offset / 220.0).floor().clamp(0, 9999);
      if (index != _estimatedVerseIndex) {
        _estimatedVerseIndex = index;
        ref.read(lastReadProvider.notifier).updateVerseIndex(index);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  void _navigateToChapter(
    Map<String, dynamic> chapter, {
    required bool isNext,
  }) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => SurahScreen(chapter: chapter),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween(
            begin: Offset(isNext ? 1.0 : -1.0, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterId = widget.chapter['id'] as int;
    final lang = ref.watch(selectedQuranLanguageProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);
    final translationFontSize = (fontSize * 15.0 / 24.0).clamp(10.0, 22.0);
    final versesAsync = ref.watch(surahVersesProvider(chapterId));
    final chaptersAsync = ref.watch(chaptersProvider);

    Map<String, dynamic>? prevChapter;
    Map<String, dynamic>? nextChapter;
    chaptersAsync.whenData((chapters) {
      final idx = chapters.indexWhere((c) => (c['id'] as int) == chapterId);
      if (idx > 0) prevChapter = chapters[idx - 1];
      if (idx >= 0 && idx < chapters.length - 1) {
        nextChapter = chapters[idx + 1];
      }
    });

    return Scaffold(
      backgroundColor: QuranColors.bg(context),
      appBar: AppBar(
        backgroundColor: QuranColors.appBar(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chapter['name_arabic'] as String? ?? '',
              style: const TextStyle(
                fontFamily: 'ScheherazadeNew',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              widget.chapter['name_simple'] as String? ?? '',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
        actions: [
          _LangSelector(
            currentLang: lang,
            onChanged: (l) =>
                ref.read(selectedQuranLanguageProvider.notifier).state = l,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          versesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white38, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Bağlantı hatası. Lütfen tekrar deneyin.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (verses) {
              final extraItems = (_showBismillah ? 1 : 0) + 1;
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: verses.length + extraItems,
                itemBuilder: (context, index) {
                  if (_showBismillah && index == 0) {
                    return _BismillahHeader(fontSize: fontSize);
                  }
                  final verseIndex = _showBismillah ? index - 1 : index;
                  if (verseIndex == verses.length) {
                    return _NavFooter(
                      prevChapter: prevChapter,
                      nextChapter: nextChapter,
                      onPrev: prevChapter != null
                          ? () =>
                                _navigateToChapter(prevChapter!, isNext: false)
                          : null,
                      onNext: nextChapter != null
                          ? () => _navigateToChapter(nextChapter!, isNext: true)
                          : null,
                    );
                  }
                  final verse = verses[verseIndex];
                  final verseNumber =
                      verse['verse_number'] as int? ?? (verseIndex + 1);
                  final verseKey =
                      verse['verse_key'] as String? ??
                      '$chapterId:$verseNumber';
                  final arabicText = verse['text_uthmani'] as String? ?? '';
                  final translation = translationText(verse, lang);
                  final trText = translationText(verse, 'tr');

                  // Staggered entrance animation
                  final cappedIdx = verseIndex.clamp(0, 10);
                  final begin = cappedIdx * 0.07;
                  final end = (begin + 0.30).clamp(0.0, 1.0);
                  final anim = CurvedAnimation(
                    parent: _enterController,
                    curve: Interval(begin, end, curve: Curves.easeOut),
                  );

                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(anim),
                      child: _VerseItem(
                        surahId: chapterId,
                        surahName:
                            widget.chapter['name_simple'] as String? ?? '',
                        number: verseNumber,
                        verseKey: verseKey,
                        arabic: arabicText,
                        translation: translation,
                        trText: trText,
                        fontSize: fontSize,
                        translationFontSize: translationFontSize,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Floating font size buttons
          Positioned(
            right: 16,
            bottom: 40,
            child: Column(
              children: [
                _FloatingFontBtn(
                  icon: Icons.add,
                  onTap: () =>
                      ref.read(arabicFontSizeProvider.notifier).increase(),
                ),
                const SizedBox(height: 8),
                _FloatingFontBtn(
                  icon: Icons.remove,
                  onTap: () =>
                      ref.read(arabicFontSizeProvider.notifier).decrease(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating font size button ─────────────────────────────────────────────────

class _FloatingFontBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _FloatingFontBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.88),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ── Bismillah header ──────────────────────────────────────────────────────────

class _BismillahHeader extends StatelessWidget {
  final double fontSize;
  const _BismillahHeader({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'ScheherazadeNew',
          fontSize: fontSize + 2,
          color: AppTheme.lightGreen,
          height: 2.0,
        ),
      ),
    );
  }
}

// ── Navigation footer ─────────────────────────────────────────────────────────

class _NavFooter extends StatelessWidget {
  final Map<String, dynamic>? prevChapter;
  final Map<String, dynamic>? nextChapter;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _NavFooter({
    required this.prevChapter,
    required this.nextChapter,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Row(
        children: [
          if (onPrev != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_left, size: 18),
                label: Text(
                  prevChapter!['name_simple'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
          if (onPrev != null && onNext != null) const SizedBox(width: 12),
          if (onNext != null)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNext,
                icon: Text(
                  nextChapter!['name_simple'] as String? ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                label: const Icon(Icons.chevron_right, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Language selector ─────────────────────────────────────────────────────────

class _LangSelector extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onChanged;

  const _LangSelector({required this.currentLang, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangChip(
            label: 'TR',
            selected: currentLang == 'tr',
            onTap: () => onChanged('tr'),
          ),
          _LangChip(
            label: 'EN',
            selected: currentLang == 'en',
            onTap: () => onChanged('en'),
          ),
          _LangChip(
            label: 'FR',
            selected: currentLang == 'fr',
            onTap: () => onChanged('fr'),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}

// ── Verse item ────────────────────────────────────────────────────────────────

class _VerseItem extends ConsumerWidget {
  final int surahId;
  final String surahName;
  final int number;
  final String verseKey;
  final String arabic;
  final String translation;
  final String trText;
  final double fontSize;
  final double translationFontSize;

  const _VerseItem({
    required this.surahId,
    required this.surahName,
    required this.number,
    required this.verseKey,
    required this.arabic,
    required this.translation,
    required this.trText,
    required this.fontSize,
    required this.translationFontSize,
  });

  void _showOptions(BuildContext context, WidgetRef ref) {
    final isFav = ref.read(favoritesProvider.notifier).isFavorite(verseKey);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2F1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                '$surahName — $verseKey',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined, color: Colors.white70),
              title: Text(
                'Arapça metni kopyala',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await Clipboard.setData(ClipboardData(text: arabic));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kopyalandı!',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate, color: Colors.white70),
              title: Text(
                'Tercümeyi kopyala',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await Clipboard.setData(ClipboardData(text: translation));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Kopyalandı!',
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      duration: const Duration(seconds: 1),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? Colors.amber : Colors.white70,
              ),
              title: Text(
                isFav ? 'Favorilerden çıkar' : 'Favorilere ekle',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                ref.read(favoritesProvider.notifier).toggle({
                  'surahId': surahId,
                  'surahName': surahName,
                  'verseNumber': number,
                  'verseKey': verseKey,
                  'arabic': arabic,
                  'trText': trText,
                });
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref
        .watch(favoritesProvider)
        .any((f) => f['verseKey'] == verseKey);

    return GestureDetector(
      onLongPress: () => _showOptions(context, ref),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: QuranColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: QuranColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.lightGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (isFav)
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: fontSize,
                color: Colors.white,
                height: 2.0,
              ),
            ),
            if (translation.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: QuranColors.divider(context)),
              const SizedBox(height: 10),
              Text(
                translation,
                style: GoogleFonts.poppins(
                  fontSize: translationFontSize,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
