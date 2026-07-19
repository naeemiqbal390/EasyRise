import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/alarm_service.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmService.instance.init();
  await _requestPermissions();
  runApp(const EasyRiseApp());
}

Future<void> _requestPermissions() async {
  // Notifications (Android 13+) — needed to show the alarm notification.
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  // Exact alarm scheduling (Android 12+) — needed for the alarm to fire
  // at the precise minute instead of being batched/delayed by the OS.
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class EasyRiseApp extends StatelessWidget {
  const EasyRiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyRise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
