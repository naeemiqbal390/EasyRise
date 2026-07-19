import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import '../models/alarm_entry.dart';
import '../services/alarm_service.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';
import '../widgets/streak_chain_widget.dart';
import 'set_alarm_screen.dart';
import 'ringing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AlarmEntry> _alarms = [];
  int _currentStreak = 0;
  int _bestStreak = 0;
  List<String> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    // If the app was opened because an alarm is ringing, jump straight to
    // the puzzle screen instead of the alarm list.
    Alarm.ringing.listen((alarmSet) {
      for (final a in alarmSet.alarms) {
        final matching = _alarms.where((x) => x.id == a.id);
        final label = matching.isNotEmpty ? matching.first.label : 'Alarm';
        final difficulty =
            matching.isNotEmpty ? matching.first.puzzleDifficulty : 1;
        if (mounted) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RingingScreen(
              alarmId: a.id,
              label: label,
              difficulty: difficulty,
            ),
          ));
        }
      }
    });
  }

  Future<void> _bootstrap() async {
    await StreakService.instance.checkForBrokenStreak();
    final alarms = await AlarmService.instance.loadAlarms();
    final stats = await StreakService.instance.getStats();
    await AlarmService.instance.rescheduleAllEnabled(alarms);
    setState(() {
      _alarms = alarms..sort((a, b) {
        final at = a.hour * 60 + a.minute;
        final bt = b.hour * 60 + b.minute;
        return at.compareTo(bt);
      });
      _currentStreak = stats['current'] as int;
      _bestStreak = stats['best'] as int;
      _history = (stats['history'] as List<String>);
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await AlarmService.instance.saveAlarms(_alarms);
    await AlarmService.instance.rescheduleAllEnabled(_alarms);
  }

  Future<void> _addOrEdit({AlarmEntry? existing}) async {
    final result = await Navigator.of(context).push<AlarmEntry>(
      MaterialPageRoute(builder: (_) => SetAlarmScreen(existing: existing)),
    );
    if (result == null) return;
    setState(() {
      if (existing != null) {
        final idx = _alarms.indexWhere((a) => a.id == existing.id);
        if (idx != -1) _alarms[idx] = result;
      } else {
        _alarms.add(result);
      }
      _alarms.sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
    });
    await _persist();
  }

  Future<void> _toggle(AlarmEntry alarm, bool value) async {
    setState(() => alarm.enabled = value);
    await _persist();
  }

  Future<void> _delete(AlarmEntry alarm) async {
    await AlarmService.instance.cancel(alarm.id);
    setState(() => _alarms.removeWhere((a) => a.id == alarm.id));
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('EasyRise')),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          children: [
            _buildStreakCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your alarms',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                Text('${_alarms.length}',
                    style: const TextStyle(color: AppColors.inkFaint)),
              ],
            ),
            const SizedBox(height: 12),
            if (_alarms.isEmpty) _buildEmptyState(),
            for (final alarm in _alarms) _buildAlarmCard(alarm),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        backgroundColor: AppColors.pinkDeep,
        icon: const Icon(Icons.add),
        label: const Text('Add alarm'),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  color: AppColors.pinkDeep, size: 28),
              const SizedBox(width: 8),
              Text(
                '$_currentStreak day streak',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink),
              ),
              const Spacer(),
              Text('best $_bestStreak',
                  style: const TextStyle(color: AppColors.inkFaint)),
            ],
          ),
          const SizedBox(height: 16),
          StreakChainWidget(history: _history),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.alarm_add_rounded,
              size: 48, color: AppColors.inkFaint),
          const SizedBox(height: 12),
          const Text('No alarms yet',
              style: TextStyle(color: AppColors.inkFaint)),
          const SizedBox(height: 4),
          const Text('Tap "Add alarm" to set your first one.',
              style: TextStyle(color: AppColors.inkFaint, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(AlarmEntry alarm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _addOrEdit(existing: alarm),
        onLongPress: () => _confirmDelete(alarm),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm.timeLabel,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: alarm.enabled
                          ? AppColors.ink
                          : AppColors.inkFaint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${alarm.label} · ${alarm.repeatLabel}',
                    style: const TextStyle(
                        color: AppColors.inkFaint, fontSize: 13),
                  ),
                ],
              ),
            ),
            Switch(
              value: alarm.enabled,
              onChanged: (v) => _toggle(alarm, v),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AlarmEntry alarm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete alarm?'),
        content: Text('This will remove your ${alarm.timeLabel} alarm.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _delete(alarm);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
