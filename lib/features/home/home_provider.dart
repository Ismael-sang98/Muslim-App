import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/prayer_api_service.dart';
import '../../core/api/api_exceptions.dart';
import '../../core/hive/hive_service.dart';
import '../../core/hive/models/horaires_jour_model.dart';
import '../../core/hive/models/prayer_cache_model.dart';
import '../../core/notifications/notification_service.dart';
import '../settings/settings_provider.dart';

// ─── Data freshness ───────────────────────────────────────────────────────────

enum DataFreshness { fresh, offline, stale }

// ─── Prayer state ─────────────────────────────────────────────────────────────

sealed class PrayerDataState {}

class PrayerDataLoading extends PrayerDataState {}

class PrayerDataLoaded extends PrayerDataState {
  final List<HorairesJourModel> horaires;
  final DataFreshness freshness;

  PrayerDataLoaded(this.horaires, this.freshness);
}

class PrayerDataError extends PrayerDataState {
  final String message;
  final bool hasCache;

  PrayerDataError(this.message, {this.hasCache = false});
}

// ─── Next prayer info ─────────────────────────────────────────────────────────

class NextPrayerInfo {
  final String prayerKey;
  final String timeString;
  final DateTime scheduledAt;

  const NextPrayerInfo({
    required this.prayerKey,
    required this.timeString,
    required this.scheduledAt,
  });

  Duration get remaining => scheduledAt.difference(DateTime.now());
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PrayerDataNotifier extends StateNotifier<PrayerDataState> {
  final PrayerApiService _api;
  final String _villeId;
  final Ref _ref;

  PrayerDataNotifier(this._api, this._villeId, this._ref)
      : super(PrayerDataLoading()) {
    _loadData();
  }

  Future<void> _loadData() async {
    if (_villeId.isEmpty) {
      state = PrayerDataError('Şehir seçilmedi');
      return;
    }

    final moisAnnee = PrayerCacheModel.currentMoisAnnee();
    final cached = HiveService.getCache(_villeId, moisAnnee);

    // Cache fresh (< 24h) → show immediately, reschedule notifications
    if (cached != null && cached.isFresh) {
      state = PrayerDataLoaded(cached.horairesMensuels, DataFreshness.fresh);
      final settings = _ref.read(settingsProvider);
      unawaited(NotificationService.scheduleMonthlyPrayers(
        horaires: cached.horairesMensuels,
        notificationsActives: settings.notificationsActives,
        minutesAvantRappel: settings.minutesAvantRappel,
      ));
      unawaited(NotificationService.updatePersistentNotification(
          cached.horairesMensuels));
      return;
    }

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    final isConnected = connectivity.any(
      (r) => r != ConnectivityResult.none,
    );

    if (isConnected) {
      try {
        final raw = await _api.fetchMonthlyPrayers(_villeId);
        final horaires =
            raw.map(HorairesJourModel.fromJson).toList();

        final newCache = PrayerCacheModel()
          ..moisAnnee = moisAnnee
          ..villeId = _villeId
          ..horairesMensuels = horaires
          ..cachedAt = DateTime.now();

        await HiveService.saveCache(newCache);
        state = PrayerDataLoaded(horaires, DataFreshness.fresh);

        // Schedule notifications for this month
        final settings = _ref.read(settingsProvider);
        await NotificationService.scheduleMonthlyPrayers(
          horaires: horaires,
          notificationsActives: settings.notificationsActives,
          minutesAvantRappel: settings.minutesAvantRappel,
        );
        unawaited(NotificationService.updatePersistentNotification(horaires));
      } on ApiException catch (e) {
        if (cached != null) {
          final freshness = cached.isStale
              ? DataFreshness.stale
              : DataFreshness.offline;
          state = PrayerDataLoaded(cached.horairesMensuels, freshness);
          final settings = _ref.read(settingsProvider);
          unawaited(NotificationService.scheduleMonthlyPrayers(
            horaires: cached.horairesMensuels,
            notificationsActives: settings.notificationsActives,
            minutesAvantRappel: settings.minutesAvantRappel,
          ));
          unawaited(NotificationService.updatePersistentNotification(
              cached.horairesMensuels));
        } else {
          state = PrayerDataError(e.message);
        }
      }
    } else {
      if (cached != null) {
        final freshness =
            cached.isStale ? DataFreshness.stale : DataFreshness.offline;
        state = PrayerDataLoaded(cached.horairesMensuels, freshness);
        final settings = _ref.read(settingsProvider);
        unawaited(NotificationService.scheduleMonthlyPrayers(
          horaires: cached.horairesMensuels,
          notificationsActives: settings.notificationsActives,
          minutesAvantRappel: settings.minutesAvantRappel,
        ));
        unawaited(NotificationService.updatePersistentNotification(
            cached.horairesMensuels));
      } else {
        state = PrayerDataError('İnternet bağlantısı yok ve önbellek bulunamadı');
      }
    }
  }

  Future<void> refresh() async {
    state = PrayerDataLoading();
    await _loadData();
  }
}

// ─── Provider family by villeId ───────────────────────────────────────────────

final prayerDataProvider = StateNotifierProvider.family<PrayerDataNotifier,
    PrayerDataState, String>(
  (ref, villeId) => PrayerDataNotifier(
    ref.read(prayerApiServiceProvider),
    villeId,
    ref,
  ),
);

// ─── Derived providers ────────────────────────────────────────────────────────

final todayHorairesProvider = Provider.family<HorairesJourModel?, String>(
  (ref, villeId) {
    final state = ref.watch(prayerDataProvider(villeId));
    if (state is! PrayerDataLoaded) return null;

    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      return state.horaires.firstWhere((h) => h.date == todayStr);
    } catch (_) {
      return null;
    }
  },
);

final nextPrayerProvider = Provider.family<NextPrayerInfo?, String>(
  (ref, villeId) {
    final today = ref.watch(todayHorairesProvider(villeId));
    if (today == null) return null;

    final now = DateTime.now();
    final reference = DateTime(now.year, now.month, now.day);

    for (final key in HorairesJourModel.prayerKeys) {
      final prayerDateTime = today.timeAsDateTime(key, reference);
      if (prayerDateTime.isAfter(now)) {
        return NextPrayerInfo(
          prayerKey: key,
          timeString: today.timeForPrayer(key),
          scheduledAt: prayerDateTime,
        );
      }
    }

    // All prayers passed → next is imsak of tomorrow
    final tomorrow = reference.add(const Duration(days: 1));
    return NextPrayerInfo(
      prayerKey: 'imsak',
      timeString: today.imsak,
      scheduledAt: today.timeAsDateTime('imsak', tomorrow),
    );
  },
);

// Exact alarm permission check
final exactAlarmGrantedProvider = FutureProvider<bool>((ref) async {
  return NotificationService.canScheduleExactAlarms();
});

// Current active prayer (the one whose window we're currently in)
final currentPrayerProvider = Provider.family<String?, String>(
  (ref, villeId) {
    final today = ref.watch(todayHorairesProvider(villeId));
    if (today == null) return null;

    final now = DateTime.now();
    final reference = DateTime(now.year, now.month, now.day);
    final keys = HorairesJourModel.prayerKeys;

    String? current;
    for (final key in keys) {
      final dt = today.timeAsDateTime(key, reference);
      if (dt.isBefore(now) || dt.isAtSameMomentAs(now)) {
        current = key;
      }
    }
    return current;
  },
);
