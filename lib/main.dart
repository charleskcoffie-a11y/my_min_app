import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/gemini_service.dart';
import 'core/notification_service.dart';

import 'features/home/home_screen_redesigned.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/hymns/hymns_screen.dart';
import 'features/christian_calendar/christian_calendar_screen.dart';
import 'features/more/more_screen.dart';
import 'widgets/modern_bottom_nav.dart';
import 'core/appointment_notification_service.dart';
import 'secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();
  await AppointmentNotificationService().initialize();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  const apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  final geminiService = GeminiService(apiKey);

  runApp(MinistryApp(geminiService: geminiService));
}


class MinistryApp extends StatelessWidget {
  final GeminiService geminiService;

  const MinistryApp({super.key, required this.geminiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ministry App',
      theme: AppTheme.lightTheme,
      routes: {
        // Routes removed - use navigation in screens instead
      },
      home: MainTabs(geminiService: geminiService),
    );
  }
}

class MainTabs extends StatefulWidget {
  final GeminiService geminiService;

  const MainTabs({super.key, required this.geminiService});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreenRedesigned(),
      const HymnsScreen(),
      const ChristianCalendarScreen(),
      TasksScreen(gemini: widget.geminiService),
      MoreScreen(geminiService: widget.geminiService),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
