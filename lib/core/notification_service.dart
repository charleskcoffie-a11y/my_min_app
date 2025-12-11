import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(InitializationSettings(android: android, iOS: ios));

    // Initialize timezone data and use UTC
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    if (kDebugMode) print('Using UTC timezone for notifications');

    _initialized = true;
  }

  Future<void> schedule(int id, String title, String body, DateTime when) async {
    if (!_initialized) await init();
    final scheduled = tz.TZDateTime.from(when, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'pastoral_tasks',
      'Pastoral Tasks',
      channelDescription: 'Reminders for pastoral tasks',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    final iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
