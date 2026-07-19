import 'dart:math';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/streak_service.dart';
import '../theme/app_theme.dart';

/// Full-screen puzzle the user must solve to silence the alarm.
/// Difficulty 1 = easy (single digit), 2 = medium (two-digit), 3 = hard
/// (three numbers / multiplication) — set per-alarm.
class RingingScreen extends StatefulWidget {
  final int alarmId;
  final String label;
  final int difficulty;

  const RingingScreen({
    super.key,
    required this.alarmId,
    required this.label,
    this.difficulty = 1,
  });

  @override
  State<RingingScreen> createState() => _RingingScreenState();
}

class _RingingScreenState extends State<RingingScreen>
    with SingleTickerProviderStateMixin {
  late int _a, _b, _answer;
  String _op = '+';
  final TextEditingController _controller = TextEditingController();
  bool _wrong = false;
  bool _solved = false;
  int? _newStreak;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _generateProblem();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _generateProblem() {
    final rnd = Random();
    switch (widget.difficulty) {
      case 3:
        _a = rnd.nextInt(12) + 2;
        _b = rnd.nextInt(12) + 2;
        _op = '×';
        _answer = _a * _b;
        break;
      case 2:
        _a = rnd.nextInt(80) + 10;
        _b = rnd.nextInt(80) + 10;
        _op = rnd.nextBool() ? '+' : '-';
        if (_op == '-' && _b > _a) {
          final tmp = _a;
          _a = _b;
          _b = tmp;
        }
        _answer = _op == '+' ? _a + _b : _a - _b;
        break;
      default:
        _a = rnd.nextInt(9) + 1;
        _b = rnd.nextInt(9) + 1;
        _op = '+';
        _answer = _a + _b;
    }
  }

  Future<void> _submit() async {
    final input = int.tryParse(_controller.text.trim());
    if (input == null) return;
    if (input == _answer) {
      HapticFeedback.mediumImpact();
      await Alarm.stop(widget.alarmId);
      final streak = await StreakService.instance.recordSuccess();
      if (!mounted) return;
      setState(() {
        _solved = true;
        _newStreak = streak;
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _wrong = true;
        _controller.clear();
        _generateProblem(); // fresh problem on a wrong answer — no guessing loops
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(() => _wrong = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // no cheating by pressing back
      child: Scaffold(
        backgroundColor: AppColors.mint,
        body: SafeArea(
          child: _solved ? _buildSolvedView() : _buildPuzzleView(),
        ),
      ),
    );
  }

  Widget _buildPuzzleView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_twilight_rounded,
              size: 56, color: AppColors.mintDeep),
          const SizedBox(height: 12),
          Text(widget.label,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink)),
          const SizedBox(height: 28),
          const Text('Solve to silence the alarm',
              style: TextStyle(fontSize: 15, color: AppColors.inkFaint)),
          const SizedBox(height: 12),
          Text(
            '$_a $_op $_b = ?',
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 24),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _wrong ? AppColors.danger : Colors.transparent,
                width: 2,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
              textAlign: TextAlign.center,
              autofocus: true,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                hintText: 'Your answer',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          if (_wrong) ...[
            const SizedBox(height: 10),
            const Text('Not quite — new problem, try again',
                style: TextStyle(color: AppColors.danger, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkDeep,
              ),
              child: const Text("I'm awake"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolvedView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_fire_department_rounded,
              size: 72, color: AppColors.pinkDeep),
          const SizedBox(height: 16),
          Text(
            '$_newStreak day${_newStreak == 1 ? '' : 's'} streak',
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nicely done. Have a good one.',
            style: TextStyle(fontSize: 15, color: AppColors.inkFaint),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text('Back to alarms'),
            ),
          ),
        ],
      ),
    );
  }
}
