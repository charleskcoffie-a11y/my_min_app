import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/daily_verse.dart';
import '../repositories/daily_verse_repository.dart';
import '../services/devotional_ai_service.dart';
import '../core/gemini_service.dart';

/// Service for managing local notifications, especially Verse of the Day
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int dailyVerseNotificationId = 1;

  // Settings (can be moved to preferences later)
  static const String notificationChannelId = 'devotion_verses';
  static const String notificationChannelName = 'Daily Verse';

  NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  /// Initialize the notification service
  /// Call this once in main() or during app startup
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // Create notification channels (Android 8.0+)
    await _createNotificationChannels();

    // Request iOS notification permissions
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _isInitialized = true;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      notificationChannelName,
      importance: Importance.high,
      description: 'Daily Verse of the Day notifications',
      sound: RawResourceAndroidNotificationSound('notification'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Schedule daily verse notification
  /// [time] - TimeOfDay to send notification (e.g. 6:00 AM)
  /// [verse] - The verse to include in the notification
  /// [customMessage] - Optional AI-generated custom message
  Future<void> scheduleDailyVerseNotification({
    required TimeOfDay time,
    required DailyVerse verse,
    String? customMessage,
  }) async {
    if (!_isInitialized) await init();

    try {
      // Cancel any existing notification
      await _notificationsPlugin.cancel(dailyVerseNotificationId);

      // Get current timezone
      final location = tz.local;
      var scheduledDate = tz.TZDateTime(
        location,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Use custom message if provided, otherwise use truncated verse
      final notificationBody = customMessage ?? verse.getTruncatedText();

      await _notificationsPlugin.zonedSchedule(
        dailyVerseNotificationId,
        verse.fullReference,
        notificationBody,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            notificationChannelName,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'Daily Verse',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'notification.caf',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: verse.id, // Pass verse ID so we can fetch it when tapped
      );

      print('Daily verse notification scheduled for ${scheduledDate.toString()}');
    } catch (e) {
      print('Error scheduling daily verse notification: $e');
      throw Exception('Failed to schedule daily verse notification: $e');
    }
  }

  /// Callback when notification is received while app is in foreground
  Future<void> _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    // Handle notification received in foreground
    print('Notification received: $title - $body');
  }

  /// Callback when notification is tapped
  Future<void> _onSelectNotification(
    NotificationResponse notificationResponse,
  ) async {
    final payload = notificationResponse.payload;
    print('Notification tapped with payload: $payload');
    // This can be handled by the app's navigation system
  }

  /// Show a test notification immediately
  Future<void> showTestNotification({required DailyVerse verse}) async {
    if (!_isInitialized) await init();

    await _notificationsPlugin.show(
      999, // Test notification ID
      verse.fullReference,
      verse.getTruncatedText(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          notificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'notification.caf',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: verse.id,
    );
  }

  /// Cancel the daily verse notification
  Future<void> cancelDailyVerseNotification() async {
    await _notificationsPlugin.cancel(dailyVerseNotificationId);
  }

  /// Check if notifications are enabled (iOS)
  Future<bool> areNotificationsEnabled() async {
    final platform = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final enabled = await platform?.requestPermissions(
          alert: false,
          badge: false,
          sound: false,
        ) ??
        false;
    return enabled;
  }
}

/// Helper to easily schedule the daily verse with AI-generated notification
/// Call this from your app startup code
Future<void> setupDailyVerseNotification({
  required TimeOfDay notificationTime,
  required int notificationHour,
  required int notificationMinute,
  required GeminiService gemini,
}) async {
  try {
    final notificationService = NotificationService();
    await notificationService.init();

    final repository = DailyVerseRepository();
    final verse = await repository.getVerseForToday();

    if (verse != null) {
      // Generate AI notification message
      String notificationBody = verse.getTruncatedText();
      
      try {
        final aiService = DevotionalAIService(gemini);
        notificationBody = await aiService.generateNotificationMessage(verse);
      } catch (e) {
        print('Failed to generate AI notification, using verse text: $e');
      }

      await notificationService.scheduleDailyVerseNotification(
        time: TimeOfDay(hour: notificationHour, minute: notificationMinute),
        verse: verse,
        customMessage: notificationBody,
      );
    }
  } catch (e) {
    print('Error setting up daily verse notification: $e');
  }
}
