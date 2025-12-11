// EXAMPLE: How to integrate into your main.dart
// 
// Add this to your main() function:

import 'package:my_min_app/core/notification_service_verse.dart';
import 'package:my_min_app/features/devotion/devotion_verse_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (your existing code)
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // NEW: Initialize and schedule daily verse notification
  // This will:
  // 1. Initialize the notification service
  // 2. Fetch today's verse from Supabase
  // 3. Schedule it to notify at 6:00 AM every day
  try {
    await setupDailyVerseNotification(
      notificationTime: const TimeOfDay(hour: 6, minute: 0),
      notificationHour: 6,
      notificationMinute: 0,
    );
  } catch (e) {
    print('Error setting up verse notifications: $e');
  }

  runApp(const MinistryApp());
}

// ============================================================================
// In your MaterialApp, add this route:
// ============================================================================

class MinistryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ministry App',
      theme: AppTheme.lightTheme,
      routes: {
        // Your existing routes...
        '/verse-of-the-day': (_) => const DevotionVerseScreen(),
        '/verse': (context) {
          // If coming from notification, pass verse ID
          final args = ModalRoute.of(context)?.settings.arguments;
          final verseId = args is String ? args : null;
          return DevotionVerseScreen(verseId: verseId);
        },
      },
      home: MainTabs(geminiService: geminiService),
    );
  }
}

// ============================================================================
// Add button to your UI to access the screen:
// ============================================================================

// Example: In a menu or quick access grid
ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(context, '/verse-of-the-day'),
  icon: const Icon(Icons.book),
  label: const Text('Verse of the Day'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6A1B9A),
  ),
)

// ============================================================================
// Example: Add to your navigation drawer
// ============================================================================

ListTile(
  leading: const Icon(Icons.book),
  title: const Text('Verse of the Day'),
  onTap: () {
    Navigator.pushNamed(context, '/verse-of-the-day');
  },
)

// ============================================================================
// Optional: Handle notification tap to navigate to verse screen
// ============================================================================

// In your notification callback handler, you might add:
onDidReceiveNotificationResponse: (NotificationResponse response) {
  // response.payload contains the verse ID
  if (response.payload != null) {
    Navigator.pushNamed(
      context,
      '/verse',
      arguments: response.payload,
    );
  }
}

// ============================================================================
// Example SQL to add sample verses to Supabase:
// ============================================================================
// Run this in Supabase SQL Editor to add sample verses
/*
INSERT INTO daily_verses (reference, translation, text, image_url, date)
VALUES 
(
  'Proverbs 18:12',
  'NLT',
  'Haughtiness goes before destruction; humility precedes honor.',
  'https://images.unsplash.com/photo-1469022563149-aa64dbd37dae?w=800',
  '2025-12-11'
),
(
  'John 3:16',
  'KJV',
  'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.',
  'https://images.unsplash.com/photo-1456162588500-7a8e9bedf840?w=800',
  '2025-12-12'
),
(
  'Philippians 4:8',
  'NLT',
  'And now, dear brothers and sisters, one final thing. Fix your thoughts on what is true, and honorable, and right, and pure, and lovely, and admirable. Think about things that are excellent and worthy of praise.',
  'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=800',
  '2025-12-13'
);

// Or without dates (will use most recent):

INSERT INTO daily_verses (reference, translation, text, image_url)
VALUES 
(
  'Romans 12:2',
  'NLT',
  'Don't copy the behavior and customs of this world, but let God transform you into a new person by changing the way you think.',
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800'
);
*/

// ============================================================================
// Changing the notification time (customization example)
// ============================================================================

// To change from 6:00 AM to 7:30 AM, in main.dart:
await setupDailyVerseNotification(
  notificationTime: const TimeOfDay(hour: 7, minute: 30),
  notificationHour: 7,
  notificationMinute: 30,
);

// ============================================================================
// Future enhancement: User preferences for notification time
// ============================================================================

// In your settings screen or user profile:
class VersNotificationSettings {
  bool enableNotifications = true;
  TimeOfDay notificationTime = const TimeOfDay(hour: 6, minute: 0);

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('verse_notifications_enabled', enableNotifications);
    await prefs.setString('verse_notification_time', 
      '${notificationTime.hour}:${notificationTime.minute}');
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    enableNotifications = prefs.getBool('verse_notifications_enabled') ?? true;
    final timeStr = prefs.getString('verse_notification_time') ?? '6:0';
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 6;
    final minute = int.tryParse(parts[1]) ?? 0;
    notificationTime = TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> applySettings() async {
    if (enableNotifications) {
      await setupDailyVerseNotification(
        notificationTime: notificationTime,
        notificationHour: notificationTime.hour,
        notificationMinute: notificationTime.minute,
      );
    } else {
      final service = NotificationService();
      await service.cancelDailyVerseNotification();
    }
  }
}
