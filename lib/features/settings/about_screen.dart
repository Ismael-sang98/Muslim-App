import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
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
    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          SafeArea(
            child: Column(
              children: [
                // Floated header (no opaque band)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
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
                      Text(
                        AppLocalizations.of(context).about,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.darkGreen,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
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
                            color: AppTheme.lightGreen,
                          ),
                        ),

                        Text(
                          'v$_version',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            letterSpacing: -0.3,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),

                        const SizedBox(height: 32),

                        _InfoCard(
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
                          children: [
                            _LinkRow(
                              icon: Icons.code,
                              label: 'GitHub',
                              onTap: () => _launch(
                                'https://github.com/Ismael-sang98/Muslim-App',
                              ),
                            ),
                            _Divider(),
                            _LinkRow(
                              icon: Icons.email_outlined,
                              label: AppLocalizations.of(context).contact,
                              onTap: () =>
                                  _launch('mailto:ismaelsang98@gmail.com'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        Text(
                          '© 2026 Ismael Sanogo\nTüm hakları saklıdır',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.4),
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
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

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 16,
      blur: 16,
      borderColor: Colors.white.withValues(alpha: 0.14),
      padding: EdgeInsets.zero,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppTheme.lightGreen),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
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
            Icon(icon, size: 20, color: AppTheme.lightGreen),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 52,
    endIndent: 0,
    color: Colors.white.withValues(alpha: 0.10),
  );
}
