import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A satisfying, GitHub-contribution-graph-style row of dots showing the
/// last few weeks of solved mornings. Filled mint dot = solved that day.
/// This visual is intentionally the biggest "accomplishment" payoff in the
/// app — designed to be glanced at first thing every morning.
class StreakChainWidget extends StatelessWidget {
  final List<String> history; // list of 'yyyy-M-d' strings
  final int weeksToShow;

  const StreakChainWidget({
    super.key,
    required this.history,
    this.weeksToShow = 8,
  });

  @override
  Widget build(BuildContext context) {
    final historySet = history.toSet();
    final today = DateTime.now();
    final days = weeksToShow * 7;
    final start = today.subtract(Duration(days: days - 1));

    // Build a 7-row x N-column grid (columns = weeks), oldest to newest.
    final columns = <List<DateTime>>[];
    DateTime cursor = start.subtract(Duration(days: start.weekday - 1)); // back to Monday
    while (cursor.isBefore(today.add(const Duration(days: 1)))) {
      final week = List.generate(7, (i) => cursor.add(Duration(days: i)));
      columns.add(week);
      cursor = cursor.add(const Duration(days: 7));
    }

    String key(DateTime d) =>
        '${d.year}-${d.month}-${d.day}';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: [
          for (final week in columns)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Column(
                children: [
                  for (final day in week)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: _Dot(
                        filled: historySet.contains(key(day)),
                        isFuture: day.isAfter(today),
                        isToday: key(day) == key(today),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool filled;
  final bool isFuture;
  final bool isToday;

  const _Dot({
    required this.filled,
    required this.isFuture,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (isFuture) {
      color = Colors.transparent;
    } else if (filled) {
      color = AppColors.mintDeep;
    } else {
      color = const Color(0xFFEFEBE4);
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: isToday && !filled
            ? Border.all(color: AppColors.pinkDeep, width: 1.5)
            : null,
      ),
    );
  }
}
