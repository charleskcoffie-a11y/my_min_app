// EXAMPLE: How to integrate daily verse into your main.dart
//
// 1. Add this to your main() function to initialize and schedule daily verse:
//
// await setupDailyVerseNotification(
//   notificationHour: 6,
//   notificationMinute: 0,
// );
//
// 2. Add this route to your MaterialApp:
//
// '/verse-of-the-day': (_) => const DevotionVerseScreen(),
//
// 3. Add a button to access (example):
//
// ElevatedButton.icon(
//   onPressed: () => Navigator.pushNamed(context, '/verse-of-the-day'),
//   icon: const Icon(Icons.book),
//   label: const Text('Verse of the Day'),
// )
//
// 4. Handle notification taps (optional in your notification handler):
//
// onDidReceiveNotificationResponse: (NotificationResponse response) {
//   if (response.payload != null) {
//     Navigator.pushNamed(context, '/verse', arguments: response.payload);
//   }
// }
//
// ============================================================================
// SQL to add sample verses to Supabase daily_verses table:
// ============================================================================
//
// INSERT INTO daily_verses (reference, translation, text, image_url, date)
// VALUES 
// ('Proverbs 18:12', 'NLT', 'Haughtiness goes before destruction...', '', '2025-12-11'),
// ('John 3:16', 'KJV', 'For God so loved the world...', '', '2025-12-12');

