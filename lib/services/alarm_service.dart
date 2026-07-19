import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_entry.dart';

/// Central place for everything alarm-related: persistence (SharedPreferences,
/// intentionally lightweight — no database needed for this data size) and
/// scheduling with the native alarm plugin.
class AlarmService {
  AlarmService._();
  static final AlarmService instance = AlarmService._();

  static const _storageKey = 'easyrise_alarms_v1';

  Future<void> init() async {
    await Alarm.init();
  }

  Future<List<AlarmEntry>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return AlarmEntry.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAlarms(List<AlarmEntry> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, AlarmEntry.encodeList(alarms));
  }

  /// Computes the next DateTime this alarm should ring at, given its
  /// hour/minute and (optional) repeat days.
  DateTime nextOccurrence(AlarmEntry alarm) {
    final now = DateTime.now();
    var candidate =
        DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);

    if (!alarm.isRepeating) {
      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      return candidate;
    }

    // Repeating: find the next enabled weekday (0=Mon..6=Sun) from today.
    for (int i = 0; i < 8; i++) {
      final day = candidate.add(Duration(days: i));
      final weekdayIndex = day.weekday - 1; // Mon=0
      final isToday = i == 0;
      if (alarm.repeatDays[weekdayIndex] &&
          (!isToday || day.isAfter(now))) {
        return DateTime(
            day.year, day.month, day.day, alarm.hour, alarm.minute);
      }
    }
    return candidate.add(const Duration(days: 1));
  }

  Future<void> schedule(AlarmEntry alarm) async {
    if (!alarm.enabled) {
      await Alarm.stop(alarm.id);
      return;
    }
    final dateTime = nextOccurrence(alarm);
    final settings = AlarmSettings(
      id: alarm.id,
      dateTime: dateTime,
      assetAudioPath: null, // uses the device's default alarm sound
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: false,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.9,
        fadeDuration: const Duration(seconds: 8),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: 'Time to rise 🌤️',
        body: alarm.label,
        stopButton: null, // no easy dismiss — solving the puzzle is the point
      ),
    );
    await Alarm.set(alarmSettings: settings);
  }

  Future<void> cancel(int id) async {
    await Alarm.stop(id);
  }

  Future<void> rescheduleAllEnabled(List<AlarmEntry> alarms) async {
    for (final alarm in alarms) {
      if (alarm.enabled) {
        await schedule(alarm);
      } else {
        await Alarm.stop(alarm.id);
      }
    }
  }
}
