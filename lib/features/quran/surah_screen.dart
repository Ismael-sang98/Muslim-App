import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/quran_colors.dart';
import '../../l10n/app_localizations.dart';
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
  final Map<String, GlobalKey> _verseKeys = {};
  bool _hasScrolled = false;
  double _listCacheExtent = 250.0;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();

    final chapterId = widget.chapter['id'] as int;
    _showBismillah = chapterId != 9;
    final surahName = widget.chapter['name_simple'] as String? ?? '';

    // Pre-position the controller so the ListView renders near the target verse
    // on first attach, making the GlobalKey available for _scrollToVerse.
    final target = widget.targetVerseNumber;
    final bismillahOffset = _showBismillah ? 280.0 : 0.0;
    if (target != null && target > 1) {
      // Large cacheExtent so the target verse is guaranteed to be rendered even
      // when the 280px/verse estimate diverges from actual card heights.
      // 120px safety margin per verse covers heights up to ~400px average.
      _listCacheExtent = ((target - 1) * 120.0).clamp(250.0, double.maxFinite);
    }
    _scrollController = ScrollController(
      initialScrollOffset: (target != null && target > 1)
          ? ((target - 1) * 280.0 + bismillahOffset).clamp(0.0, double.maxFinite)
          : 0.0,
    );

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lastReadProvider.notifier).save(
        surahId: chapterId,
        surahName: surahName,
        verseIndex: (widget.targetVerseNumber ?? 1) - 1,
      );
      _enterController.forward();
    });

    // Debounced scroll tracking: uses actual rendered GlobalKeys instead of
    // pixel division, so the saved verse is always accurate regardless of
    // variable card heights or a large initialScrollOffset.
    _scrollController.addListener(() {
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(milliseconds: 400), _saveCurrentPosition);
    });
  }

  // Finds the rendered verse whose top edge is closest to the AppBar bottom
  // and saves it as the "last read" position.
  void _saveCurrentPosition() {
    if (!mounted) return;
    int? bestNum;
    double bestDist = double.maxFinite;
    for (final entry in _verseKeys.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;
      final rb = ctx.findRenderObject() as RenderBox?;
      if (rb == null) continue;
      final y = rb.localToGlobal(Offset.zero).dy;
      final dist = (y - kToolbarHeight).abs();
      if (dist < bestDist) {
        bestDist = dist;
        final parts = entry.key.split(':');
        if (parts.length >= 2) bestNum = int.tryParse(parts[1]);
      }
    }
    if (bestNum != null) {
      final idx = bestNum - 1;
      if (idx != _estimatedVerseIndex) {
        _estimatedVerseIndex = idx;
        ref.read(lastReadProvider.notifier).updateVerseIndex(idx);
      }
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
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

  Future<void> _scrollToVerse(String verseKey, {bool resetCache = false}) async {
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    final key = _verseKeys[verseKey];
    if (key?.currentContext != null) {
      await Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      // Release the large cacheExtent now that initial navigation is done.
      if (resetCache && mounted && _listCacheExtent > 250.0) {
        setState(() => _listCacheExtent = 250.0);
      }
    }
  }

  void _showReciterSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1A2F1A),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(ctx).size.height * 0.6,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ReciterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AudioState>(audioProvider, (prev, next) {
      if (next.currentVerseKey != null &&
          next.currentVerseKey != prev?.currentVerseKey) {
        _scrollToVerse(next.currentVerseKey!);
      }
    });

    final chapterId = widget.chapter['id'] as int;
    final lang = ref.watch(selectedQuranLanguageProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);
    final translationFontSize = (fontSize * 15.0 / 24.0).clamp(10.0, 22.0);
    final versesAsync = ref.watch(surahVersesProvider(chapterId));
    final chaptersAsync = ref.watch(chaptersProvider);

    // Scroll to target verse once the FutureProvider has resolved.
    // _hasScrolled prevents re-scrolling on subsequent rebuilds.
    if (!_hasScrolled &&
        versesAsync.hasValue &&
        widget.targetVerseNumber != null &&
        widget.targetVerseNumber! > 1) {
      _hasScrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToVerse('$chapterId:${widget.targetVerseNumber}', resetCache: true);
      });
    }

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.chapter['name_arabic'] as String? ?? '',
              style: const TextStyle(
                fontFamily: 'Lateef',
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              widget.chapter['name_simple'] as String? ?? '',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Colors.white70),
            tooltip: AppLocalizations.of(context).reciter,
            onPressed: () => _showReciterSheet(context),
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
                      AppLocalizations.of(context).connectionErrorRetry,
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
              final verseOrder = verses
                  .map((v) => v['verse_key'] as String? ?? '')
                  .where((k) => k.isNotEmpty)
                  .toList();
              final extraItems = (_showBismillah ? 1 : 0) + 1;
              return ListView.builder(
                controller: _scrollController,
                // ignore: deprecated_member_use
                cacheExtent: _listCacheExtent,
                padding: const EdgeInsets.only(bottom: 120),
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
                  final itemKey = _verseKeys.putIfAbsent(verseKey, GlobalKey.new);

                  return FadeTransition(
                    key: itemKey,
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
                        verseOrder: verseOrder,
                      ),
                    ),
                  );
                },
              );
            },
          ),
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
          Consumer(
            builder: (_, cRef, child) {
              final audio = cRef.watch(audioProvider);
              if (!audio.isActive) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _MiniAudioBar(audio: audio),
              );
            },
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
      child: RichText(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        strutStyle: StrutStyle(
          fontFamily: 'ScheherazadeNew',
          fontSize: fontSize + 2,
          height: 2.0,
          forceStrutHeight: true,
        ),
        text: TextSpan(
          text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          style: TextStyle(
            fontFamily: 'ScheherazadeNew',
            fontSize: fontSize + 2,
            color: AppTheme.lightGreen,
            height: 2.0,
          ),
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
  final List<String> verseOrder;

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
    required this.verseOrder,
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
                AppLocalizations.of(context).copyArabic,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await Clipboard.setData(ClipboardData(text: arabic));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).copied,
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
                AppLocalizations.of(context).copyTranslation,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(sheetCtx);
                await Clipboard.setData(ClipboardData(text: translation));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).copied,
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
                isFav
                    ? AppLocalizations.of(context).removeFromFavorites
                    : AppLocalizations.of(context).addToFavorites,
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
    final isActive = ref.watch(
        audioProvider.select((s) => s.currentVerseKey == verseKey));

    return GestureDetector(
      onLongPress: () => _showOptions(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryGreen.withValues(alpha: 0.13)
              : QuranColors.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppTheme.primaryGreen.withValues(alpha: 0.40)
                : QuranColors.border(context),
          ),
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
                Row(
                  children: [
                    _AudioBtn(
                      verseKey: verseKey,
                      surahId: surahId,
                      verseOrder: verseOrder,
                    ),
                    if (isFav) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              strutStyle: StrutStyle(
                fontFamily: 'ScheherazadeNew',
                fontSize: fontSize,
                height: 2.0,
                forceStrutHeight: true,
              ),
              text: TextSpan(
                text: arabic,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: fontSize,
                  color: Colors.white,
                  height: 2.0,
                ),
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

// ── Audio play button (per verse) ─────────────────────────────────────────────

class _AudioBtn extends ConsumerWidget {
  final String verseKey;
  final int surahId;
  final List<String> verseOrder;

  const _AudioBtn({
    required this.verseKey,
    required this.surahId,
    required this.verseOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(audioProvider);
    final reciterId = ref.watch(selectedReciterProvider);
    final audioUrls = ref.watch(chapterAudioProvider((surahId, reciterId)));
    final isCurrent = audio.currentVerseKey == verseKey;
    final isLoading = isCurrent && audio.isLoading;
    final isUrlsLoading = audioUrls.isLoading && !isCurrent;
    final isPlaying = isCurrent && audio.isPlaying;

    return GestureDetector(
      onTap: () {
        if (isCurrent) {
          ref.read(audioProvider.notifier).togglePause();
        } else {
          final urls = audioUrls.valueOrNull;
          if (urls != null) {
            ref.read(audioProvider.notifier).playChapter(
              startVerseKey: verseKey,
              urls: urls,
              verseOrder: verseOrder,
            );
          }
        }
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isCurrent
              ? AppTheme.primaryGreen
              : AppTheme.primaryGreen.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: (isLoading || isUrlsLoading)
            ? const Padding(
                padding: EdgeInsets.all(7),
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 18,
                color: Colors.white,
              ),
      ),
    );
  }
}

// ── Mini audio bar (bottom of screen) ────────────────────────────────────────

class _MiniAudioBar extends ConsumerWidget {
  final AudioState audio;
  const _MiniAudioBar({required this.audio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkGreen.withValues(alpha: 0.97),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Icon(Icons.headphones_rounded, color: AppTheme.lightGreen, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                audio.currentVerseKey ?? '',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
              onPressed: () => ref.read(audioProvider.notifier).playPrevious(),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(
                audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
              ),
              onPressed: () => ref.read(audioProvider.notifier).togglePause(),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
              onPressed: () => ref.read(audioProvider.notifier).playNext(),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.stop_rounded, color: Colors.white54),
              onPressed: () => ref.read(audioProvider.notifier).stop(),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reciter selection bottom sheet ────────────────────────────────────────────

class _ReciterSheet extends ConsumerWidget {
  const _ReciterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reciters = ref.watch(recitersProvider);
    final selected = ref.watch(selectedReciterProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 4),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Récitateur',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: reciters.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
            error: (_, s) => Center(
              child: Text(
                AppLocalizations.of(context).loadingError,
                style: GoogleFonts.poppins(color: Colors.white54),
              ),
            ),
            data: (list) => ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final r = list[i];
                final id = r['id'] as int;
                final name = r['reciter_name'] as String? ?? '';
                final style = r['style'] as String? ?? '';
                final isSelected = id == selected;
                return ListTile(
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(
                      color: isSelected ? AppTheme.lightGreen : Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: style.isNotEmpty
                      ? Text(
                          style,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppTheme.lightGreen)
                      : null,
                  onTap: () {
                    ref.read(audioProvider.notifier).stop();
                    ref.read(selectedReciterProvider.notifier).select(id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}
