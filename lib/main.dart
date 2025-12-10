import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_theme.dart';
import 'core/gemini_service.dart';

import 'features/home/home_screen.dart';
import 'features/devotion/devotion_screen.dart';
import 'features/counselling/counselling_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/hymns/hymns_screen.dart';
import 'features/standing_orders/standing_orders_screen.dart';
import 'features/christian_calendar/christian_calendar_screen.dart';
import 'secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      const HomeScreen(),
      DevotionScreen(gemini: widget.geminiService),
      CounsellingScreen(gemini: widget.geminiService),
      TasksScreen(gemini: widget.geminiService),
      const HymnsScreen(),
      const StandingOrdersScreen(),
      const ChristianCalendarScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Devotion'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Counsel'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Hymns'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
        ],
      ),
    );
  }
}
