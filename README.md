# my_min_app

A comprehensive Flutter ministerial management application with appointment scheduling, standing orders management, counseling notes, pastoral tasks, and more.

## ✨ Features

### Core Features
- **Minister's Schedule & Appointment Book** - Weekly, monthly, and agenda views with notifications
- **Standing Orders** - Dual-mode (database & document) management with favorites and search
- **Counseling Notes** - Encrypted case management with PDF export
- **Pastoral Tasks** - Task tracking by category with reminders
- **Christian Calendar** - Liturgical seasons and observances
- **Sermon Builder** - Sermon preparation and management

### Technical Features
- ✅ **Error Handling** - Global ErrorHandler with Firebase Crashlytics integration
- ✅ **Data Validation** - ModelValidator for all input types
- ✅ **Caching** - CacheManager for optimized performance
- ✅ **Enhanced Theme** - Material 3 with semantic design tokens
- ✅ **Empty States** - User-friendly empty and error states
- ✅ **Pull-to-Refresh** - Modern UI pattern for data refresh
- ✅ **Unit Tests** - Core service tests included
- ✅ **Security** - Supabase RLS policies and encryption
- ✅ **Firebase Crashlytics** - Automatic error tracking and logging

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

- **[DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md)** - Complete developer guide with examples and patterns
- **[IMPLEMENTATION_SUMMARY.md](docs/IMPLEMENTATION_SUMMARY.md)** - Overview of all improvements and how to use them
- **[FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md)** - Firebase and Crashlytics setup instructions
- **[SUPABASE_RLS_SETUP.md](docs/SUPABASE_RLS_SETUP.md)** - Row-Level Security policies for data protection

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10.3+
- Dart 3.10.3+
- Supabase account
- Firebase project (optional, for Crashlytics)

### Installation

1. Clone the repository
```bash
git clone <repo-url>
cd my_min_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase (optional)
```bash
flutterfire configure
```

4. Update Supabase credentials in `lib/secrets.dart`
```dart
const String supabaseUrl = 'YOUR_SUPABASE_URL';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

5. Run the app
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── core/                    # Core services
│   ├── error_handler.dart   # Global error handling
│   ├── model_validator.dart # Data validation
│   ├── cache_manager.dart   # Caching layer
│   ├── app_theme.dart       # Material 3 theme
│   ├── encryption_service.dart
│   ├── appointment_notification_service.dart
│   ├── pdf_export_service.dart
│   ├── gemini_service.dart
│   └── app_theme.dart
├── models/                  # Data models
│   ├── task.dart
│   ├── appointment.dart
│   └── ...
├── features/                # Feature screens
│   ├── pastoral_tasks/
│   ├── schedule/
│   ├── standing_orders/
│   ├── counseling_notes/
│   ├── christian_calendar/
│   └── hymns/
├── widgets/                 # Reusable widgets
│   └── empty_state_widget.dart
└── main.dart                # App entry point

docs/                        # Documentation
├── DEVELOPMENT_GUIDE.md
├── IMPLEMENTATION_SUMMARY.md
├── FIREBASE_SETUP.md
└── SUPABASE_RLS_SETUP.md

test/                        # Unit tests
├── core/
│   ├── cache_manager_test.dart
│   └── model_validator_test.dart
```

## 📦 Dependencies

- **supabase_flutter** - Backend database
- **firebase_core** - Firebase services
- **firebase_crashlytics** - Error tracking
- **flutter_local_notifications** - Appointment reminders
- **flutter_secure_storage** - Secure credential storage
- **encrypt** - Data encryption
- **pdf** - PDF generation
- **table_calendar** - Calendar widget
- **intl** - Internationalization

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run specific test:
```bash
flutter test test/core/cache_manager_test.dart
```

Run with coverage:
```bash
flutter test --coverage
```

## 📊 Code Quality

Analyze code:
```bash
flutter analyze
```

Format code:
```bash
dart format lib/
```

## 🔐 Security

- **Supabase RLS Policies** - User data isolation
- **Encrypted Storage** - Secure local storage
- **Environment Variables** - Sensitive data protection
- **Firebase Crashlytics** - Error monitoring

See [SUPABASE_RLS_SETUP.md](docs/SUPABASE_RLS_SETUP.md) for security configuration.

## 🎨 Theming

The app uses Material 3 with a custom color scheme. Modify colors in `lib/core/app_theme.dart`:

```dart
// Colors
AppTheme.primaryColor
AppTheme.successColor
AppTheme.warningColor
AppTheme.errorColor

// Spacing
AppTheme.spacing16
AppTheme.spacing24

// Typography
Theme.of(context).textTheme.headlineLarge
Theme.of(context).textTheme.bodyMedium
```

## 🤝 Contributing

1. Read the [DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md)
2. Follow the established patterns in `lib/features/pastoral_tasks/` as reference
3. Add error handling using `ErrorHandler`
4. Validate data using `ModelValidator`
5. Add tests for new features
6. Run `flutter analyze` before submitting

## 🐛 Bug Reports

If you find a bug, check Firebase Crashlytics console for error details.

## 📝 License

This project is private. See LICENSE file for details.

## 📞 Support

For documentation questions, see the docs/ directory.
For technical issues, check Firebase Crashlytics or contact the maintainers.

---

**Last Updated**: December 2025
**Flutter Version**: 3.10.3+
**Status**: Production-Ready ✅

