# Platform-Specific Setup for Local Notifications

This guide provides setup steps for enabling local notifications (reminders) on Android and iOS for the Pastoral Task Tracker feature.

## Overview

The app uses `flutter_local_notifications`, `timezone`, and `flutter_native_timezone` to schedule reminder notifications for pastoral tasks. The `NotificationService` singleton manages scheduling and cancellation across the app lifecycle.

## Android Setup

### 1. Update Android Manifest Permissions

Edit `android/app/src/main/AndroidManifest.xml` and add the following permissions (inside the `<manifest>` tag, before `<application>`):

```xml
<!-- Notification permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM_PERMISSION" />
```

### 2. Set Android Notification Channel

The `NotificationService` creates a channel named "pastoral_tasks" with high importance. This is compatible with Android 8.0+. Ensure your `compileSdkVersion` in `android/app/build.gradle.kts` is at least 31.

Example `build.gradle.kts`:
```kotlin
android {
    compileSdk = 35
    ...
    defaultConfig {
        minSdk = 21
        targetSdk = 35
    }
}
```

### 3. Request Notification Permission (Android 13+)

For Android 13 (API 33) and higher, the app must request the `POST_NOTIFICATIONS` permission at runtime. The `flutter_local_notifications` plugin will request this automatically when `initialize()` is called.

If you want explicit control, you can use the `permission_handler` package:
1. Add dependency: `flutter pub add permission_handler`
2. Request permission before calling `NotificationService().init()`:
   ```dart
   import 'package:permission_handler/permission_handler.dart';
   
   final status = await Permission.notification.request();
   // Then initialize NotificationService
   ```

### 4. Verify Gradle Configuration

Ensure your gradle wrapper is up to date. For Flutter projects, this is usually automatic, but you can manually check `android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https://services.gradle.org/distributions/gradle-8.x-all.zip
```

## iOS Setup

### 1. Update Xcode Project Deployment Target

The `flutter_local_notifications` plugin requires iOS 11.0 or higher.

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the "Runner" project in the Project Navigator.
3. Select the "Runner" target.
4. Go to **Build Settings** and set:
   - **Minimum Deployments Target**: iOS 11.0 or higher

Alternatively, edit `ios/Podfile` and uncomment/set:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

### 2. Request Notification Permission

iOS requires explicit user permission. The `NotificationService.init()` method calls:
```dart
DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
)
```

This triggers the system notification permission dialog on first app launch. The user must grant permission for notifications to work.

### 3. Verify Info.plist

iOS may prompt the user with a custom message. You can customize this by adding to `ios/Runner/Info.plist`:

```xml
<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>
```

(This is usually already present for Flutter projects.)

### 4. Run on Device or Simulator

Notifications are more reliable on actual devices. To test:
```bash
flutter run -d <device_id>
```

To list available devices:
```bash
flutter devices
```

## Web Considerations

Web does not support `flutter_local_notifications` in the same way as mobile. The current implementation:
- Gracefully skips notification scheduling on web.
- Tasks are stored in Supabase and can be retrieved on any device.
- Consider using the browser Notification API (requires user permission) or omitting reminders on web.

For web support, you can conditionally import:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (!kIsWeb) {
  await NotificationService().init();
}
```

## Troubleshooting

### "flutter_local_notifications" plugin not found
- Run `flutter pub get` to fetch dependencies.
- Run `flutter clean && flutter pub get` if the issue persists.

### Notifications not appearing
- **Android**: Ensure the app has notification permission (check Settings > Apps > [Your App] > Permissions).
- **iOS**: Check that notifications are enabled (Settings > Notifications > [Your App]).
- Verify the reminder time is in the future (not past).

### Timezone errors
- The `flutter_native_timezone` plugin detects your device's timezone. If it fails, the app falls back to UTC.
- Check your device timezone settings and ensure they are correct.

### gradle build errors
- Run `flutter clean && flutter pub get && flutter pub upgrade`.
- Update Android SDK tools in Android Studio.

## Testing Notifications Locally

1. Create a task with a future reminder date/time.
2. Note the task ID and notification ID.
3. Wait for the scheduled time (you can set a reminder ~1 minute in the future for quick testing).
4. Check that a notification appears in your device's notification center.
5. Tap the notification to verify it opens the app (optional — app can launch in background).

## Resources

- [flutter_local_notifications documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Channels](https://developer.android.com/training/notify-user/channels)
- [iOS User Notifications](https://developer.apple.com/documentation/usernotifications)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)

## Next Steps

Once notifications are set up:
1. Run `flutter pub get` to ensure all dependencies are installed.
2. Build and run the app: `flutter run` (or specify a device with `-d`).
3. Test the Pastoral Task Tracker by creating a task with a reminder.
4. Verify the notification appears at the scheduled time.
