import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the "solved my wake-up puzzle today" streak — this is the core
/// dopamine loop of the app, so it's kept simple, visible, and honest
/// (streak only increments once per calendar day, and breaks if a day is
/// missed, same mental model as Duolingo/GitHub streaks people already
/// understand).
class StreakService {
  StreakService._();
  static final StreakService instance = StreakService._();

  static const _currentStreakKey = 'easyrise_current_streak';
  static const _bestStreakKey = 'easyrise_best_streak';
  static const _lastSolvedDateKey = 'easyrise_last_solved_date';
  static const _historyKey = 'easyrise_history_dates'; // for the chain widget

  Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'current': prefs.getInt(_currentStreakKey) ?? 0,
      'best': prefs.getInt(_bestStreakKey) ?? 0,
      'lastSolved': prefs.getString(_lastSolvedDateKey),
      'history': prefs.getStringList(_historyKey) ?? <String>[],
    };
  }

  String _todayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Call this the moment a puzzle is solved and the alarm is dismissed.
  /// Returns the updated current streak count.
  Future<int> recordSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _todayKey(now);
    final lastSolved = prefs.getString(_lastSolvedDateKey);

    if (lastSolved == todayKey) {
      // Already recorded today (e.g. multiple alarms) — no double counting.
      return prefs.getInt(_currentStreakKey) ?? 0;
    }

    int current = prefs.getInt(_currentStreakKey) ?? 0;
    if (lastSolved != null) {
      final yesterday = _todayKey(now.subtract(const Duration(days: 1)));
      current = (lastSolved == yesterday) ? current + 1 : 1;
    } else {
      current = 1;
    }

    final best = prefs.getInt(_bestStreakKey) ?? 0;
    final history = prefs.getStringList(_historyKey) ?? <String>[];
    history.add(todayKey);
    // keep last 84 days (12 weeks) for the chain widget
    final trimmed =
        history.length > 84 ? history.sublist(history.length - 84) : history;

    await prefs.setInt(_currentStreakKey, current);
    await prefs.setInt(_bestStreakKey, current > best ? current : best);
    await prefs.setString(_lastSolvedDateKey, todayKey);
    await prefs.setStringList(_historyKey, trimmed);

    return current;
  }

  /// Call on app launch to silently reset the streak if the user missed a
  /// day entirely (so the home screen shows an honest number, not a stale
  /// one from before a gap).
  Future<void> checkForBrokenStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSolved = prefs.getString(_lastSolvedDateKey);
    if (lastSolved == null) return;
    final now = DateTime.now();
    final today = _todayKey(now);
    final yesterday = _todayKey(now.subtract(const Duration(days: 1)));
    if (lastSolved != today && lastSolved != yesterday) {
      await prefs.setInt(_currentStreakKey, 0);
    }
  }
}
