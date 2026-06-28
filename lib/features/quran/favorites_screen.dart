import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/quran_colors.dart';
import 'quran_provider.dart';
import 'surah_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: QuranColors.bg(context),
      appBar: AppBar(
        backgroundColor: QuranColors.appBar(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Favoriler',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    color: Colors.white24,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz favori eklemediniz.',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bir ayete uzun basarak favorilere ekleyebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white24,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                return _FavoriteTile(
                  favorite: fav,
                  onTap: () {
                    final surahId = fav['surahId'] as int? ?? 1;
                    final verseNumber = fav['verseNumber'] as int? ?? 1;
                    ref.read(chaptersProvider.future).then((chapters) {
                      final chapter = chapters.firstWhere(
                        (c) => (c['id'] as int) == surahId,
                        orElse: () => <String, dynamic>{},
                      );
                      if (chapter.isNotEmpty && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SurahScreen(
                              chapter: chapter,
                              targetVerseNumber: verseNumber,
                            ),
                          ),
                        );
                      }
                    });
                  },
                  onRemove: () =>
                      ref.read(favoritesProvider.notifier).remove(
                            fav['verseKey'] as String? ?? '',
                          ),
                );
              },
            ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final Map<String, dynamic> favorite;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteTile({
    required this.favorite,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final surahName = favorite['surahName'] as String? ?? '';
    final verseKey = favorite['verseKey'] as String? ?? '';
    final arabic = favorite['arabic'] as String? ?? '';
    final trText = favorite['trText'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
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
                    const SizedBox(width: 8),
                    Text(
                      surahName,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Lateef',
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.white,
                height: 1.8,
              ),
            ),
            if (trText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),
              const SizedBox(height: 8),
              Text(
                trText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
