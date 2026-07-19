import 'package:flutter/material.dart';
import '../models/alarm_entry.dart';
import '../theme/app_theme.dart';

class SetAlarmScreen extends StatefulWidget {
  final AlarmEntry? existing;
  const SetAlarmScreen({super.key, this.existing});

  @override
  State<SetAlarmScreen> createState() => _SetAlarmScreenState();
}

class _SetAlarmScreenState extends State<SetAlarmScreen> {
  late TimeOfDay _time;
  late List<bool> _repeatDays;
  late TextEditingController _labelController;
  late String _puzzleType;
  late int _difficulty;

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _time = TimeOfDay(hour: e?.hour ?? 7, minute: e?.minute ?? 0);
    _repeatDays = List.of(e?.repeatDays ?? List.filled(7, false));
    _labelController = TextEditingController(text: e?.label ?? '');
    _puzzleType = e?.puzzleType ?? 'math';
    _difficulty = e?.puzzleDifficulty ?? 1;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.mintDeep,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final result = AlarmEntry(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.remainder(1000000000),
      hour: _time.hour,
      minute: _time.minute,
      label: _labelController.text.trim().isEmpty
          ? 'Alarm'
          : _labelController.text.trim(),
      repeatDays: _repeatDays,
      enabled: widget.existing?.enabled ?? true,
      puzzleType: _puzzleType,
      puzzleDifficulty: _difficulty,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New alarm' : 'Edit alarm'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.mintDeep)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 36),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  _time.format(context),
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Repeat',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final selected = _repeatDays[i];
              return GestureDetector(
                onTap: () => setState(() => _repeatDays[i] = !selected),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      selected ? AppColors.mintDeep : AppColors.card,
                  child: Text(
                    _dayLetters[i],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.inkFaint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          const Text('Label',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                hintText: 'e.g. Morning workout',
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Puzzle difficulty',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 4),
          const Text(
            "Harder puzzles keep you awake longer — pick what actually gets you out of bed.",
            style: TextStyle(fontSize: 13, color: AppColors.inkFaint),
          ),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('Easy')),
              ButtonSegment(value: 2, label: Text('Medium')),
              ButtonSegment(value: 3, label: Text('Hard')),
            ],
            selected: {_difficulty},
            onSelectionChanged: (s) => setState(() => _difficulty = s.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.mintDeep,
              selectedForegroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
