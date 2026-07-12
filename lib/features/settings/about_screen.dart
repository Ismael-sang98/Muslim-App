import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '—';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).about,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.darkGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset('assets/Logo.png'),
            ),

            const SizedBox(height: 16),

            Text(
              'Muslim',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),

            Text(
              'v$_version',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            _InfoCard(
              isDark: isDark,
              children: [
                _InfoRow(
                  icon: Icons.data_object,
                  label: AppLocalizations.of(context).dataSource,
                  value: 'Diyanet İşleri Başkanlığı',
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: AppLocalizations.of(context).developer,
                  value: 'Ismael Sanogo',
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.smartphone,
                  label: 'Platform',
                  value: 'Android',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InfoCard(
              isDark: isDark,
              children: [
                _LinkRow(
                  icon: Icons.code,
                  label: 'GitHub',
                  onTap: () =>
                      _launch('https://github.com/Ismael-sang98/Muslim-App'),
                ),
                _Divider(),
                _LinkRow(
                  icon: Icons.email_outlined,
                  label: AppLocalizations.of(context).contact,
                  onTap: () => _launch('mailto:ismaelsang98@gmail.com'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              '© 2026 Ismael Sanogo\nTüm hakları saklıdır',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _InfoCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A23) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryGreen),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryGreen),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const Spacer(),
            const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 52, endIndent: 0);
}
