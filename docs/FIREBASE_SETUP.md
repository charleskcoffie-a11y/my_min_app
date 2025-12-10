# Firebase Setup & Crashlytics Integration

## Overview

This app integrates Firebase Crashlytics for error tracking and logging. Follow these steps to set up Firebase for your project.

## Prerequisites

- Firebase project created at [firebase.google.com](https://firebase.google.com)
- Google Cloud Console access
- Flutter CLI installed

## Installation Steps

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### 2. Add Firebase to Flutter

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This command will:
- Detect your platforms (Android, iOS, Web, etc.)
- Create Firebase projects automatically
- Generate configuration files

### 3. Add Dependencies

Dependencies are already in `pubspec.yaml`:

```yaml
firebase_core: ^3.7.0
firebase_crashlytics: ^4.2.0
```

Run `flutter pub get` to fetch them.

### 4. Configure Android

#### Android/build.gradle.kts

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.3.15")
    }
}
```

#### Android/app/build.gradle.kts

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

dependencies {
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-crashlytics-ktx")
}
```

### 5. Configure iOS

Run `cd ios && pod install --repo-update && cd ..`

### 6. Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Enable Crashlytics error reporting
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

## Usage in App

### Logging Errors

The `ErrorHandler` class automatically logs errors to Crashlytics:

```dart
final errorHandler = ErrorHandler();

try {
  // Your code here
} catch (e, stackTrace) {
  await errorHandler.logError(
    e,
    stackTrace,
    context: 'MyScreen.myMethod',
    fatal: false,  // Set to true for critical errors
  );
}
```

### Custom Logging

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Log messages
FirebaseCrashlytics.instance.log('User clicked button');

// Log custom data
await FirebaseCrashlytics.instance.setCustomKey('user_id', '12345');
```

## Firebase Console

### View Crashes

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Crashlytics** in the left menu
4. View crash reports, trends, and affected users

### Set Up Alerts

1. In Crashlytics, click **Create Alert**
2. Configure alert conditions (e.g., crash rate > 5%)
3. Add notification channels (Email, Slack, etc.)

## Debugging

### Test Crashlytics (Development Only)

Add this code to test error logging:

```dart
// Test crash (will not actually crash in debug mode)
try {
  throw Exception('Test Crashlytics error');
} catch (e, st) {
  FirebaseCrashlytics.instance.recordError(e, st);
}
```

### Disable Crashlytics in Development

```dart
// In main.dart
if (kDebugMode) {
  FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled = false;
} else {
  FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled = true;
}
```

## Best Practices

1. **Always pass context** when logging errors for better debugging
2. **Use stack traces** to understand error origin
3. **Set custom keys** for user context (user ID, app version, etc.)
4. **Enable Crashlytics only in production** for cleaner development
5. **Review crashes regularly** to identify patterns
6. **Set up alerts** for critical error rates

## Troubleshooting

### Crashlytics not showing errors

- Ensure Firebase is initialized before running app
- Check that your internet connection is active
- Verify that Crashlytics is enabled in Firebase Console
- Wait 5-10 minutes for first crash to appear

### Build errors

- Run `flutter clean && flutter pub get`
- Ensure all platform-specific configurations are updated
- Check Firebase console for any pending setup steps

## Documentation

- [Firebase Docs](https://firebase.google.com/docs)
- [Crashlytics Guide](https://firebase.google.com/docs/crashlytics)
- [Flutter Firebase Plugin](https://pub.dev/packages/firebase_core)
