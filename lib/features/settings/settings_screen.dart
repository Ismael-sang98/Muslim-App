import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/location_city_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/blob_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/location_detect_button.dart';
import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final cityName = settings.villeProvinceNom?.isNotEmpty == true
        ? settings.villeProvinceNom!
        : settings.villeNom;

    return GradientScaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: BlobBackground()),
          Column(
        children: [
          _SettingsHeader(cityName: cityName),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(brightness: Brightness.dark),
              child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                // ── APPEARANCE ───────────────────────────────────────────────
                _SettingsGroup(
                  label: l10n.sectionAppearance,
                  icon: Icons.palette_outlined,
                  color: AppTheme.accentOrange,
                  delay: 0,
                  child: _ThemeRow(
                    current: settings.themeMode,
                    onSelect: (v) =>
                        ref.read(settingsProvider.notifier).updateTheme(v),
                  ),
                ),

                const SizedBox(height: 14),

                // ── LANGUAGE ─────────────────────────────────────────────────
                _SettingsGroup(
                  label: l10n.sectionLanguage,
                  icon: Icons.translate_rounded,
                  color: const Color(0xFF00BCD4),
                  delay: 60,
                  child: _LanguageRow(
                    current: settings.langue,
                    onSelect: (v) async {
                      await ref
                          .read(settingsProvider.notifier)
                          .updateLanguage(v);
                      // Reschedule so queued notifications adopt the new language.
                      final updated = ref.read(settingsProvider);
                      final ps = ref.read(prayerDataProvider(updated.villeId));
                      if (ps is PrayerDataLoaded) {
                        await NotificationService.scheduleMonthlyPrayers(
                          horaires: ps.horaires,
                          notificationsActives: updated.notificationsActives,
                          minutesAvantRappel: updated.minutesAvantRappel,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // ── LOCATION ─────────────────────────────────────────────────
                _SettingsGroup(
                  label: l10n.sectionLocation,
                  icon: Icons.location_on_outlined,
                  color: AppTheme.primaryGreen,
                  delay: 80,
                  child: _LocationSection(settings: settings),
                ),

                const SizedBox(height: 14),

                // ── REMINDER ─────────────────────────────────────────────────
                _SettingsGroup(
                  label: l10n.sectionReminder,
                  icon: Icons.notifications_outlined,
                  color: const Color(0xFF0077FF),
                  delay: 160,
                  child: _ReminderRow(
                    current: settings.minutesAvantRappel,
                    onSelect: (minutes) async {
                      ref
                          .read(settingsProvider.notifier)
                          .updateReminderMinutes(minutes);
                      final updated = ref.read(settingsProvider);
                      final ps =
                          ref.read(prayerDataProvider(updated.villeId));
                      if (ps is PrayerDataLoaded) {
                        await NotificationService.scheduleMonthlyPrayers(
                          horaires: ps.horaires,
                          notificationsActives: updated.notificationsActives,
                          minutesAvantRappel: updated.minutesAvantRappel,
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // ── NOTIFICATIONS ────────────────────────────────────────────
                _SettingsGroup(
                  label: l10n.sectionNotifications,
                  icon: Icons.access_alarm_outlined,
                  color: const Color(0xFF9C27B0),
                  delay: 240,
                  child: Column(
                    children: HorairesJourModel.prayerKeys
                        .map(
                          (key) => NotificationToggleTile(
                            prayerKey: key,
                            todayTime: _getTodayTime(ref, key),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // ── ABOUT ────────────────────────────────────────────────────
                _SettingsGroup(
                  label: l10n.sectionAbout,
                  icon: Icons.info_outline_rounded,
                  color: AppTheme.lightGreen,
                  delay: 320,
                  child: const _AboutRow(),
                ),
              ],
            ),
            ),
          ),
        ],
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

// ── Header ─────────────────────────────────────────────────────────────────────

class _SettingsHeader extends StatelessWidget {
  final String cityName;
  const _SettingsHeader({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 20,
        24,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).settings,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          if (cityName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  cityName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Settings group card ────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int delay;
  final Widget child;

  const _SettingsGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      blur: 16,
      borderColor: Colors.white.withValues(alpha: 0.14),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.10),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    ).animate(delay: delay.ms).fadeIn(duration: 300.ms).slideY(begin: 0.12);
  }
}

// ── Theme selector ─────────────────────────────────────────────────────────────

class _ThemeRow extends StatelessWidget {
  final String current;
  final void Function(String) onSelect;

  const _ThemeRow({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final options = [
      ('light', Icons.wb_sunny_rounded, l10n.themeLight),
      ('dark', Icons.nightlight_rounded, l10n.themeDark),
      ('system', Icons.phone_iphone_rounded, l10n.themeSystem),
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = current == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                        .withValues(alpha: isDark ? 0.20 : 0.13)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    opt.$2,
                    size: 22,
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : isDark
                            ? Colors.white54
                            : Colors.black38,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    opt.$3,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : isDark
                              ? Colors.white54
                              : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Language selector ──────────────────────────────────────────────────────────

class _LanguageRow extends StatelessWidget {
  final String current;
  final void Function(String) onSelect;

  const _LanguageRow({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final options = [
      ('tr', '🇹🇷', l10n.langTurkish),
      ('en', '🇬🇧', l10n.langEnglish),
      ('fr', '🇫🇷', l10n.langFrench),
    ];

    return Row(
      children: options.map((opt) {
        final isSelected = current == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGreen
                        .withValues(alpha: isDark ? 0.20 : 0.13)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(opt.$2, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Text(
                    opt.$3,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.primaryGreen
                          : isDark
                              ? Colors.white54
                              : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Location section ───────────────────────────────────────────────────────────

class _LocationSection extends ConsumerStatefulWidget {
  final dynamic settings;
  const _LocationSection({required this.settings});

  @override
  ConsumerState<_LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<_LocationSection> {
  Province? _pendingProvince;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
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
        SizedBox(
          width: double.infinity,
          child: LocationDetectButton(
            foreground: AppTheme.primaryGreen,
            onDetected: _applyDetected,
          ),
        ),
        const SizedBox(height: 8),
        _LocationRow(
          icon: Icons.public_rounded,
          label: l10n.city,
          value: provinceNom.isNotEmpty ? provinceNom : l10n.notSelected,
          onTap: _openProvincePicker,
        ),
        Divider(
          height: 16,
          thickness: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
        _LocationRow(
          icon: Icons.location_on_rounded,
          label: l10n.district,
          value: districtNom.isNotEmpty ? districtNom : l10n.notSelected,
          onTap: hasProvince ? _openDistrictPicker : _openProvincePicker,
        ),
      ],
    );
  }

  void _openProvincePicker() {
    ref.read(villesTourquieProvider).whenData((villes) {
      _showPicker(
        title: AppLocalizations.of(context).selectProvince,
        items: villes.provinces.map((p) => (p.id, p.nom)).toList(),
        onSelect: (id, nom) {
          final province = villes.provinces.firstWhere((p) => p.id == id);
          setState(() => _pendingProvince = province);
          Navigator.pop(context);
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
        title: '${AppLocalizations.of(context).selectDistrict} — ${prov.nom}',
        items: prov.districts.map((d) => (d.id, d.nom)).toList(),
        onSelect: (id, nom) {
          Navigator.of(context).pop();
          unawaited(_updateCityAndReschedule(id, nom, prov.nom));
        },
      );
    });
  }

  void _applyDetected(GeoCityMatch match) {
    if (match.hasDistrict) {
      unawaited(_updateCityAndReschedule(
        match.districtId!,
        match.districtNom!,
        match.provinceNom,
      ));
      return;
    }
    // Province only → pre-select it and let the user pick the district.
    ref.read(villesTourquieProvider).whenData((villes) {
      final province = villes.provinces
          .where((p) => p.id == match.provinceId)
          .firstOrNull;
      if (province == null) return;
      setState(() => _pendingProvince = province);
      _openDistrictPicker();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen
                  .withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.4)
                        : AppTheme.darkGreen.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.28)
                : AppTheme.darkGreen.withValues(alpha: 0.3),
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ── Reminder row ───────────────────────────────────────────────────────────────

class _ReminderRow extends StatelessWidget {
  final int current;
  final void Function(int) onSelect;

  const _ReminderRow({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const options = [10, 20, 30];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).reminderDescription(current),
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark
                ? Colors.white60
                : AppTheme.darkGreen.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: options.map((min) {
            final isSelected = current == min;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onSelect(min),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0077FF)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    AppLocalizations.of(context).minutesShort(min),
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? Colors.white54
                              : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── About row ──────────────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  const _AboutRow();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutScreen()),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.lightGreen
                  .withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: AppTheme.lightGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              AppLocalizations.of(context).aboutApp,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? Colors.white.withValues(alpha: 0.28)
                : AppTheme.darkGreen.withValues(alpha: 0.3),
            size: 22,
          ),
        ],
      ),
    );
  }
}

// ── Simple picker sheet ────────────────────────────────────────────────────────

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
        .where(
          (item) => item.$2.toLowerCase().contains(_query.toLowerCase()),
        )
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
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchHint,
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white70),
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

