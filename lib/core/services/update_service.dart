import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const _repoOwner = 'Ismael-sang98';
  static const _repoName = 'Muslim-App';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      dev.log('UpdateService — version actuelle : $current', name: 'UpdateService');

      final res = await Dio().get(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      final tagName = res.data['tag_name'] as String? ?? '';
      final latest = tagName.replaceFirst(RegExp(r'^v'), '');
      dev.log('UpdateService — dernière version GitHub : $latest', name: 'UpdateService');

      if (latest.isEmpty || !_isNewer(latest, current)) {
        dev.log('UpdateService — pas de mise à jour (latest=$latest, current=$current)', name: 'UpdateService');
        return;
      }

      final assets = res.data['assets'] as List? ?? [];
      final apkAsset = assets.firstWhere(
        (a) => (a['name'] as String).endsWith('.apk'),
        orElse: () => null,
      );
      final apkUrl = apkAsset?['browser_download_url'] as String?;
      final releaseUrl =
          res.data['html_url'] as String? ??
          'https://github.com/$_repoOwner/$_repoName/releases';

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            'Güncelleme mevcut 🎉',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Yeni sürüm: v$latest\nMevcut sürüm: v$current',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Daha sonra',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final url = Uri.parse(apkUrl ?? releaseUrl);
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              child: Text(
                'Güncelle',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1A7A4C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e, st) {
      dev.log('UpdateService — erreur : $e', name: 'UpdateService', error: e, stackTrace: st);
    }
  }

  static bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.tryParse).toList();
    final c = current.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final lv = (i < l.length ? l[i] : null) ?? 0;
      final cv = (i < c.length ? c[i] : null) ?? 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }
}
