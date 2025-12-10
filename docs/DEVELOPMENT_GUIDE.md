# Development Guide - Improvements & Best Practices

This guide documents all improvements implemented in this release and how to use them effectively.

## Table of Contents

1. [Core Services](#core-services)
2. [Enhanced Theme System](#enhanced-theme-system)
3. [Error Handling](#error-handling)
4. [State Management](#state-management)
5. [Data Validation](#data-validation)
6. [Caching Strategy](#caching-strategy)
7. [Testing](#testing)
8. [UI Components](#ui-components)
9. [Security](#security)

---

## Core Services

### ErrorHandler Service

**Location**: `lib/core/error_handler.dart`

A singleton service for consistent error management across the app.

#### Features

- **User-friendly error messages** - Converts technical errors to readable messages
- **Firebase Crashlytics integration** - Automatic error logging
- **Multiple notification types** - Error, info, and success messages

#### Usage

```dart
final errorHandler = ErrorHandler();

// Log an error
try {
  await someAsyncOperation();
} catch (e, st) {
  await errorHandler.logError(
    e,
    st,
    context: 'MyScreen.myMethod',
    fatal: false,
  );
}

// Show error to user
errorHandler.showError(context, e, customMessage: 'Custom message');

// Show info/success
errorHandler.showInfo(context, 'Loading data...');
errorHandler.showSuccess(context, 'Data saved successfully!');
```

#### Error Message Mapping

- `FormatException` → "Invalid format. Please try again."
- `TimeoutException` → "Request timed out. Please check your connection."
- `SocketException` → "Network error. Please check your internet connection."
- `permission` in error → "Permission denied. Please check app settings."
- `auth` in error → "Authentication failed. Please log in again."

---

## Enhanced Theme System

### AppTheme with Design Tokens

**Location**: `lib/core/app_theme.dart`

A comprehensive design system with semantic colors, spacing, and typography constants.

#### Color Palette

```dart
// Primary colors
AppTheme.primaryColor        // #6A1B9A (Deep Purple)
AppTheme.primaryDark         // #2D1B3D (Dark Purple)
AppTheme.accentColor         // #7B1FA2

// Semantic colors
AppTheme.successColor        // #4CAF50 (Green)
AppTheme.warningColor        // #FFC107 (Amber)
AppTheme.errorColor          // #F44336 (Red)
AppTheme.infoColor           // #2196F3 (Blue)
```

#### Spacing Constants

```dart
AppTheme.spacing4            // 4.0
AppTheme.spacing8            // 8.0
AppTheme.spacing12           // 12.0
AppTheme.spacing16           // 16.0
AppTheme.spacing20           // 20.0
AppTheme.spacing24           // 24.0
AppTheme.spacing32           // 32.0
```

#### Text Styles

Use Material 3 text styles for consistency:

```dart
// In build method
Text(
  'Headline',
  style: Theme.of(context).textTheme.headlineLarge,
),
Text(
  'Body text',
  style: Theme.of(context).textTheme.bodyMedium,
),
```

---

## Error Handling

### Standardized Error Handling Pattern

Apply this pattern across all screens:

```dart
Future<void> _loadData() async {
  setState(() => _loading = true);
  try {
    final data = await repository.getData();
    if (!mounted) return;
    setState(() {
      _data = data;
      _errorMessage = null;
    });
  } catch (e, st) {
    if (!mounted) return;
    final message = _errorHandler.getErrorMessage(e);
    await _errorHandler.logError(e, st, context: 'ScreenName._loadData');
    setState(() => _errorMessage = message);
  }
  if (!mounted) return;
  setState(() => _loading = false);
}
```

### Key Patterns

1. **Always check `mounted`** after async operations
2. **Pass stack trace** for better error tracking
3. **Set `_errorMessage`** for UI feedback
4. **Use `getErrorMessage()`** for user-friendly errors

---

## State Management

### Proper StatefulWidget Pattern

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _repo = MyRepository();
  final _errorHandler = ErrorHandler();
  
  bool _loading = true;
  List<Item> _items = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }

  // Always check mounted after async operations
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.getItems();
      if (!mounted) return;
      setState(() {
        _items = items;
        _errorMessage = null;
      });
    } catch (e, st) {
      if (!mounted) return;
      await _errorHandler.logError(e, st, context: 'MyScreen._load');
      setState(() => _errorMessage = _errorHandler.getErrorMessage(e));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return ErrorStateWidget(
        message: _errorMessage!,
        onRetry: _load,
      );
    }
    if (_items.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: 'No Items',
        subtitle: 'Create your first item to get started',
      );
    }
    return ListView(/* ... */);
  }
}
```

---

## Data Validation

### ModelValidator Service

**Location**: `lib/core/model_validator.dart`

Validates all model inputs before saving.

#### Validation Methods

```dart
// Validate task
final errors = ModelValidator.validateTask(
  title: 'My Task',
  category: 'Work',
  priority: 'High',
  description: 'Task description',
);

if (errors.isNotEmpty) {
  errorHandler.showError(context, errors.join('\n'));
  return;
}

// Validate appointment
final apptErrors = ModelValidator.validateAppointment(
  title: 'Meeting',
  appointmentDate: DateTime.now().add(Duration(days: 1)),
  reminderAt: null,
);
```

#### Validation Rules

- **Title**: Required, max 255 characters
- **Description**: Max 5000 characters
- **Category**: Required
- **Priority**: Required
- **Appointment date**: Must be in future
- **Reminder**: Cannot be after appointment

---

## Caching Strategy

### CacheManager Service

**Location**: `lib/core/cache_manager.dart`

In-memory caching layer for repositories.

#### Usage

```dart
class MyRepository {
  final _cache = CacheManager<List<Item>>();

  Future<List<Item>> getItems() async {
    return _cache.getOrCompute('items_key', () async {
      final response = await _supabase
          .from('items')
          .select()
          .execute();
      return (response.data as List)
          .map((e) => Item.fromJson(e))
          .toList();
    });
  }

  void invalidateCache() {
    _cache.invalidate('items_key');
  }
}
```

#### Cache Configuration

```dart
// Custom cache duration
final cache = CacheManager<String>(
  defaultDuration: const Duration(minutes: 10),
);

// Get cache stats
print(cache.getCacheStats());  // "Cache size: 5 entries"
```

---

## Testing

### Unit Test Examples

#### Repository Tests

```dart
// test/features/tasks/task_repository_test.dart
void main() {
  group('TaskRepository Tests', () {
    late TaskRepository repository;

    setUp(() {
      repository = TaskRepository();
    });

    test('get all tasks returns list', () async {
      final tasks = await repository.getAllTasks();
      expect(tasks, isList);
    });

    test('create task adds to list', () async {
      await repository.createTask(
        title: 'New Task',
        category: 'Work',
        priority: 'High',
        taskDate: DateTime.now(),
      );
      final tasks = await repository.getAllTasks();
      expect(tasks.length, greaterThan(0));
    });
  });
}
```

#### Model Validation Tests

```dart
void main() {
  group('ModelValidator Tests', () {
    test('Valid task passes validation', () {
      final errors = ModelValidator.validateTask(
        title: 'Task',
        category: 'Work',
        priority: 'High',
      );
      expect(errors, isEmpty);
    });

    test('Empty title fails validation', () {
      final errors = ModelValidator.validateTask(
        title: '',
        category: 'Work',
        priority: 'High',
      );
      expect(errors, contains('Title is required'));
    });
  });
}
```

#### Cache Manager Tests

```dart
void main() {
  group('CacheManager Tests', () {
    late CacheManager<String> cache;

    setUp(() {
      cache = CacheManager<String>();
    });

    test('get returns null for missing key', () {
      expect(cache.get('missing'), isNull);
    });

    test('set and get returns cached value', () {
      cache.set('key', 'value');
      expect(cache.get('key'), equals('value'));
    });
  });
}
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/cache_manager_test.dart

# Run with coverage
flutter test --coverage
```

---

## UI Components

### EmptyStateWidget

**Location**: `lib/widgets/empty_state_widget.dart`

Displays helpful message when no data exists.

```dart
EmptyStateWidget(
  icon: Icons.task_alt_outlined,
  title: 'No Tasks Yet',
  subtitle: 'Create a new task to get started',
  actionText: 'Create Task',
  onAction: () => _showAddTaskSheet(),
)
```

### ErrorStateWidget

Displays error message with retry option.

```dart
ErrorStateWidget(
  message: 'Failed to load data',
  actionText: 'Retry',
  onRetry: _loadData,
)
```

### SkeletonListItem

Loading skeleton for list items.

```dart
// Show while loading
SkeletonListItem(count: 5)

// Or in build:
_loading ? SkeletonListItem() : ListView(/* real list */)
```

### Pull-to-Refresh

Add to any list screen:

```dart
RefreshIndicator(
  onRefresh: _refresh,
  child: ListView(/* items */),
)

Future<void> _refresh() async {
  setState(() => _refreshing = true);
  await _load();
  if (!mounted) return;
  setState(() => _refreshing = false);
}
```

---

## Security

### Row-Level Security (RLS)

All data must be protected with RLS policies. See `docs/SUPABASE_RLS_SETUP.md` for complete setup.

### API Key Rotation

1. Store keys in environment variables, not in source code
2. Use service role key only in trusted backends
3. Rotate keys quarterly

### Error Logging

Never log sensitive data:

```dart
// ✅ Good
errorHandler.logError(
  e,
  st,
  context: 'User registration failed',
);

// ❌ Bad - Don't log user data
errorHandler.logError(
  e,
  st,
  context: 'User registration failed: $email',
);
```

---

## Migration Checklist

When upgrading your screens, use this checklist:

- [ ] Add `final _errorHandler = ErrorHandler();`
- [ ] Replace `ScaffoldMessenger` with `errorHandler.show*()`
- [ ] Add validation using `ModelValidator`
- [ ] Add `_errorMessage` state variable
- [ ] Implement `_refresh()` method with `RefreshIndicator`
- [ ] Add `ErrorStateWidget` for error display
- [ ] Add `EmptyStateWidget` for no data state
- [ ] Add mounted checks after async operations
- [ ] Pass stack trace to `logError()`
- [ ] Test with different network conditions

---

## Summary of Improvements

| Improvement | Benefits |
|---|---|
| **ErrorHandler** | Consistent error UX, automatic Crashlytics logging |
| **Enhanced Theme** | Design token reusability, easier customization |
| **Validation** | Prevent invalid data, user feedback |
| **Caching** | Reduced API calls, faster app |
| **Empty States** | Better UX, reduced confusion |
| **Error States** | User understands what went wrong |
| **Pull-to-Refresh** | Modern UX pattern, data freshness |
| **Unit Tests** | Catch bugs early, regression prevention |

---

## Questions?

Refer to:
- `SUPABASE_RLS_SETUP.md` - Security setup
- `FIREBASE_SETUP.md` - Error logging setup
- Original `copilot-instructions.md` - Project architecture
