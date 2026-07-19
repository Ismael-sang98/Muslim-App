import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/hive/hive_service.dart';
import 'core/hive/models/settings_model.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_provider.dart';
import 'features/home/home_screen.dart';
import 'features/hub/hub_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/quran/quran_screen.dart';
import 'features/quran/quran_provider.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  // 2. Hive
  await HiveService.init();

  // 2b. First launch → follow the device language (if supported).
  await _applyDeviceLanguageOnFirstLaunch();

  // 3. Notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: NamazVaktiApp()));
}

/// On the very first launch (no settings yet), pick the app language from the
/// device locale when it's one we support (tr/en/fr); otherwise default to tr.
Future<void> _applyDeviceLanguageOnFirstLaunch() async {
  final box = HiveService.settingsBox;
  if (box.isNotEmpty) return; // returning user — keep their choice

  const supported = {'tr', 'en', 'fr'};
  final deviceLang =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final lang = supported.contains(deviceLang) ? deviceLang : 'tr';

  final defaults = SettingsModel.defaults()
    ..langue = lang
    ..hadithLangue = lang;
  await box.put(0, defaults);
}

class NamazVaktiApp extends ConsumerWidget {
  const NamazVaktiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final onboardingDone = ref.watch(onboardingCompleteProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: 'Namaz Vakti',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: onboardingDone ? const MainShell() : const OnboardingScreen(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _screens = [
    HomeScreen(),
    QuranScreen(),
    HubScreen(),
    SettingsScreen(),
  ];

  static const _icons = [
    Icons.home_rounded,
    Icons.auto_stories,
    Icons.menu_open,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(activeTabProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        ),
        child: IndexedStack(
          key: ValueKey(currentIndex),
          index: currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: currentIndex,
        icons: _icons,
        onTap: (i) => ref.read(activeTabProvider.notifier).state = i,
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<IconData> icons;
  final void Function(int) onTap;

  const _CustomBottomNav({
    required this.currentIndex,
    required this.icons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0C2A19)
            : AppTheme.darkGreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, -3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (i) {
            final isActive = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 72,
                height: 61,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icons[i],
                      size: 25,
                      color: isActive
                          ? AppTheme.accentOrange
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
