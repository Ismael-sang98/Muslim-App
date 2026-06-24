import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../home/home_provider.dart';
import '../settings/settings_provider.dart';

final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

final selectedDayProvider = StateProvider<HorairesJourModel?>(
  (ref) => null,
);

final calendarDataProvider = Provider<List<HorairesJourModel>>((ref) {
  final settings = ref.watch(settingsProvider);
  final state = ref.watch(prayerDataProvider(settings.villeId));
  if (state is PrayerDataLoaded) return state.horaires;
  return [];
});
