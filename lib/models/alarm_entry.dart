import 'dart:convert';

/// Which days of the week this alarm repeats on.
/// Index 0 = Monday ... 6 = Sunday (matches DateTime.weekday - 1).
class AlarmEntry {
  final int id;
  final int hour;
  final int minute;
  final String label;
  final List<bool> repeatDays; // length 7
  bool enabled;
  final String puzzleType; // 'math' | 'sequence' | 'typing'
  final int puzzleDifficulty; // 1 = easy, 2 = medium, 3 = hard

  AlarmEntry({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = 'Alarm',
    List<bool>? repeatDays,
    this.enabled = true,
    this.puzzleType = 'math',
    this.puzzleDifficulty = 1,
  }) : repeatDays = repeatDays ?? List.filled(7, false);

  bool get isRepeating => repeatDays.any((d) => d);

  String get timeLabel {
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h12:${minute.toString().padLeft(2, '0')} $period';
  }

  String get repeatLabel {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (!isRepeating) return 'Once';
    if (repeatDays.every((d) => d)) return 'Every day';
    final weekdays = repeatDays.sublist(0, 5).every((d) => d);
    final weekend = repeatDays.sublist(5, 7).every((d) => d);
    if (weekdays && !repeatDays[5] && !repeatDays[6]) return 'Weekdays';
    if (weekend && repeatDays.sublist(0, 5).every((d) => !d)) return 'Weekends';
    return [
      for (int i = 0; i < 7; i++)
        if (repeatDays[i]) names[i]
    ].join(', ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'repeatDays': repeatDays,
        'enabled': enabled,
        'puzzleType': puzzleType,
        'puzzleDifficulty': puzzleDifficulty,
      };

  factory AlarmEntry.fromJson(Map<String, dynamic> json) => AlarmEntry(
        id: json['id'] as int,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        label: json['label'] as String? ?? 'Alarm',
        repeatDays: (json['repeatDays'] as List<dynamic>?)
                ?.map((e) => e as bool)
                .toList() ??
            List.filled(7, false),
        enabled: json['enabled'] as bool? ?? true,
        puzzleType: json['puzzleType'] as String? ?? 'math',
        puzzleDifficulty: json['puzzleDifficulty'] as int? ?? 1,
      );

  static String encodeList(List<AlarmEntry> alarms) =>
      jsonEncode(alarms.map((a) => a.toJson()).toList());

  static List<AlarmEntry> decodeList(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list
        .map((e) => AlarmEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
