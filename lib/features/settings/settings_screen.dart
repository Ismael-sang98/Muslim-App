import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../onboarding/onboarding_provider.dart';
import '../home/home_provider.dart';
import '../settings/settings_provider.dart';
import 'widgets/notification_toggle_tile.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _SettingsHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // ── GÖRÜNÜM ─────────────────────────────────────────────────
                _SectionLabel('GÖRÜNÜM'),
                _WhiteCard(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _IconCircle(
                                icon: Icons.wb_sunny_outlined,
                                color: AppTheme.accentOrange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Uygulama teması',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color ??
                                            AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      'Görüntüleme modunuzu seçin',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                        color: const Color.fromARGB(
                                          255,
                                          38,
                                          129,
                                          74,
                                        ).withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          _ThemeSelector(
                            current: settings.themeMode,
                            onSelect: (v) => ref
                                .read(settingsProvider.notifier)
                                .updateTheme(v),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 0.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 16),

                // ── KONUM ───────────────────────────────────────────────────
                _SectionLabel('KONUM'),
                _WhiteCard(child: _LocationSection(settings: settings))
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 16),

                // ── HATIRLATMA ───────────────────────────────────────────────
                _SectionLabel('HATIRLATMA'),
                _WhiteCard(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _IconCircle(
                                icon: Icons.notifications_active_outlined,
                                color: const Color(0xFF0077FF),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bildirim süresi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color ??
                                            AppTheme.textDark,
                                      ),
                                    ),
                                    Text(
                                      'Her namazdan önce',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withValues(
                                                alpha: 0.5,
                                              )
                                            : AppTheme.darkGreen.withValues(
                                                alpha: 0.55,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${settings.minutesAvantRappel} dakika',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withValues(alpha: 0.85)
                                      : AppTheme.darkGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _ReminderSelector(
                            current: settings.minutesAvantRappel,
                            onSelect: (minutes) async {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateReminderMinutes(minutes);
                              final updated = ref.read(settingsProvider);
                              final villeId = updated.villeId;
                              final ps = ref.read(prayerDataProvider(villeId));
                              if (ps is PrayerDataLoaded) {
                                await NotificationService.scheduleMonthlyPrayers(
                                  horaires: ps.horaires,
                                  notificationsActives:
                                      updated.notificationsActives,
                                  minutesAvantRappel:
                                      updated.minutesAvantRappel,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 16),

                // ── BİLDİRİMLER ──────────────────────────────────────────────
                _SectionLabel('BİLDİRİMLER'),
                _WhiteCard(
                      child: Column(
                        children: [
                          ...HorairesJourModel.prayerKeys.map(
                            (key) => NotificationToggleTile(
                              prayerKey: key,
                              todayTime: _getTodayTime(ref, key),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 16),

                // ── HAKKINDA ─────────────────────────────────────────────────
                _SectionLabel('HAKKINDA'),
                _WhiteCard(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen()),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              _IconCircle(
                                icon: Icons.info_outline,
                                color: AppTheme.primaryGreen,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Uygulama hakkında',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right,
                                  color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getTodayTime(WidgetRef ref, String key) {
    final settings = ref.read(settingsProvider);
    final ps = ref.read(prayerDataProvider(settings.villeId));
    if (ps is! PrayerDataLoaded) return null;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    try {
      final today = ps.horaires.firstWhere((h) => h.date == todayStr);
      return today.timeForPrayer(key);
    } catch (_) {
      return null;
    }
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppTheme.mainGradient),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        24,
      ),
      child: Text(
        'Ayarlar',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.5)
              : AppTheme.darkGreen.withValues(alpha: 0.55),
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── White card ────────────────────────────────────────────────────────────────

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

// ── Icon circle ───────────────────────────────────────────────────────────────

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

// ── Theme selector ────────────────────────────────────────────────────────────

class _ThemeSelector extends StatelessWidget {
  final String current;
  final void Function(String) onSelect;

  const _ThemeSelector({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('light', '☀ Açık'),
      ('dark', '🌙 Koyu'),
      ('system', '⚙ Sistem'),
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = current == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 34,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(
                        255,
                        14,
                        60,
                        31,
                      ).withValues(alpha: 0.25)
                    : AppTheme.settingsBg.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : const Color(0xFFD9D9D9),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  opt.$2,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                    color: isSelected
                        ? AppTheme.darkGreen
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppTheme.darkGreen.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Location section ──────────────────────────────────────────────────────────

class _LocationSection extends ConsumerStatefulWidget {
  final dynamic settings;
  const _LocationSection({required this.settings});

  @override
  ConsumerState<_LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<_LocationSection> {
  // Province sélectionnée en attente (le district n'est pas encore confirmé)
  Province? _pendingProvince;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final provinceNom =
        _pendingProvince?.nom ??
        (settings.villeProvinceNom?.isNotEmpty == true
            ? settings.villeProvinceNom!
            : settings.villeNom);
    final districtNom = settings.villeNom;
    final hasProvince =
        _pendingProvince != null ||
        (settings.villeProvinceNom?.isNotEmpty == true);

    return Column(
      children: [
        _LocationRow(
          icon: Icons.public,
          label: 'Şehir',
          value: provinceNom.isNotEmpty ? provinceNom : 'Seçilmedi',
          onTap: _openProvincePicker,
        ),
        Divider(height: 1, color: AppTheme.settingsBg.withValues(alpha: 0.6)),
        _LocationRow(
          icon: Icons.location_on_outlined,
          label: 'İlçe',
          value: districtNom.isNotEmpty ? districtNom : 'Seçilmedi',
          onTap: hasProvince ? _openDistrictPicker : _openProvincePicker,
        ),
      ],
    );
  }

  // Accède à this.context directement — jamais passé en paramètre async
  void _openProvincePicker() {
    ref.read(villesTourquieProvider).whenData((villes) {
      _showPicker(
        title: 'İl Seçin',
        items: villes.provinces.map((p) => (p.id, p.nom)).toList(),
        onSelect: (id, nom) {
          final province = villes.provinces.firstWhere((p) => p.id == id);
          setState(() => _pendingProvince = province);
          Navigator.pop(context);
          // Cascade → ouvre directement les districts après fermeture du sheet
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted) _openDistrictPicker();
          });
        },
      );
    });
  }

  void _openDistrictPicker() {
    ref.read(villesTourquieProvider).whenData((villes) {
      Province? province = _pendingProvince;

      if (province == null) {
        final savedNom = ref.read(settingsProvider).villeProvinceNom ?? '';
        if (savedNom.isNotEmpty) {
          final matches = villes.provinces.where((p) => p.nom == savedNom);
          province = matches.isEmpty ? null : matches.first;
        }
      }

      if (province == null) {
        _openProvincePicker();
        return;
      }

      final prov = province;
      _showPicker(
        title: 'İlçe Seçin — ${prov.nom}',
        items: prov.districts.map((d) => (d.id, d.nom)).toList(),
        onSelect: (id, nom) {
          Navigator.of(context).pop();
          unawaited(_updateCityAndReschedule(id, nom, prov.nom));
        },
      );
    });
  }

  Future<void> _updateCityAndReschedule(
    String id,
    String nom,
    String provinceNom,
  ) async {
    final oldVilleId = ref.read(settingsProvider).villeId;
    await ref
        .read(settingsProvider.notifier)
        .updateCity(id, nom, provinceNom: provinceNom);
    if (oldVilleId.isNotEmpty && oldVilleId != id) {
      ref.invalidate(prayerDataProvider(oldVilleId));
    }
    await NotificationService.cancelAll();
    final newPs = ref.read(prayerDataProvider(id));
    if (newPs is PrayerDataLoaded) {
      final s = ref.read(settingsProvider);
      await NotificationService.scheduleMonthlyPrayers(
        horaires: newPs.horaires,
        notificationsActives: s.notificationsActives,
        minutesAvantRappel: s.minutesAvantRappel,
      );
    }
    if (!mounted) return;
    setState(() => _pendingProvince = null);
  }

  void _showPicker({
    required String title,
    required List<(String, String)> items,
    required void Function(String id, String nom) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.darkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _SimplePickerSheet(title: title, items: items, onSelect: onSelect),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LocationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.45)
                          : AppTheme.darkGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.darkGreen.withValues(alpha: 0.35),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reminder selector ─────────────────────────────────────────────────────────

class _ReminderSelector extends StatelessWidget {
  final int current;
  final void Function(int) onSelect;

  const _ReminderSelector({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [10, 20, 30];

    return Row(
      children: options.map((min) {
        final isSelected = current == min;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelect(min),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 66,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen.withValues(alpha: 0.25)
                    : AppTheme.settingsBg.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryGreen
                      : const Color(0xFFD9D9D9),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$min dk',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                    color: isSelected
                        ? const Color.fromARGB(255, 6, 34, 17)
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppTheme.darkGreen.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Simple picker sheet (one level: province OR district) ─────────────────────

class _SimplePickerSheet extends StatefulWidget {
  final String title;
  final List<(String, String)> items;
  final void Function(String id, String nom) onSelect;

  const _SimplePickerSheet({
    required this.title,
    required this.items,
    required this.onSelect,
  });

  @override
  State<_SimplePickerSheet> createState() => _SimplePickerSheetState();
}

class _SimplePickerSheetState extends State<_SimplePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => item.$2.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 8),
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
                widget.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Ara...',
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final item = filtered[i];
                  return ListTile(
                    title: Text(
                      item.$2,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                    ),
                    onTap: () => widget.onSelect(item.$1, item.$2),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
