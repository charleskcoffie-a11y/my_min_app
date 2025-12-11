# Verse of the Day Feature - Complete Implementation

## 📚 Overview
A complete "Verse of the Day" system with:
- ✅ Daily morning notifications
- ✅ Beautiful full-screen display with background image
- ✅ Supabase integration
- ✅ Flutter local notifications
- ✅ Reusable widgets and components
- ✅ Easy customization

---

## 📁 Files Created

### 1. **Data Model**
- **File:** `lib/models/daily_verse.dart`
- **Contains:** `DailyVerse` class with:
  - Fields: id, date, reference, translation, text, imageUrl, createdAt
  - Methods: fromMap(), toMap(), getTruncatedText(), fullReference

### 2. **Repository (Supabase Integration)**
- **File:** `lib/repositories/daily_verse_repository.dart`
- **Contains:** `DailyVerseRepository` with methods:
  - `getVerseForToday()` - Fetch today's verse or fallback to most recent
  - `getRandomVerse()` - Get a random verse
  - `getUpcomingVerses()` - Get verses for next N days
  - `getVerseById()` - Get specific verse by ID
  - `insertVerse()` - Add new verse (admin function)

### 3. **Notification Service**
- **File:** `lib/core/notification_service_verse.dart`
- **Contains:** `NotificationService` singleton with:
  - `init()` - Initialize notifications and request permissions
  - `scheduleDailyVerseNotification()` - Schedule repeating daily notification
  - `cancelDailyVerseNotification()` - Cancel the notification
  - `showTestNotification()` - Send a test notification immediately
  - Helper function: `setupDailyVerseNotification()`

### 4. **Main UI Screen**
- **File:** `lib/features/devotion/devotion_verse_screen.dart`
- **Contains:** `DevotionVerseScreen` with:
  - Full-screen background image from verse
  - Bottom white card with verse reference and text
  - Loading and error states
  - Date display
  - Support for loading specific verse by ID

### 5. **Reusable Widgets**
- **File:** `lib/widgets/verse_widgets.dart`
- **Contains:**
  - `VerseOfTheDayCard` - Quick access card for home screen
  - `ShimmerLoading` - Animated loading placeholder
  - `VerseCarousel` - Horizontal scrolling upcoming verses

### 6. **Documentation**
- **File:** `VERSE_OF_THE_DAY_GUIDE.txt` - Step-by-step integration guide
- **File:** `VERSE_INTEGRATION_EXAMPLES.dart` - Code examples and snippets

---

## 🗄️ Supabase Table Schema

Run this SQL in your Supabase SQL editor:

```sql
-- Enable UUID generation in Supabase
create extension if not exists "uuid-ossp";

-- Create the daily_verses table
create table if not exists daily_verses (
  id uuid primary key default uuid_generate_v4(),

  -- Optional specific date for Verse of the Day
  date date,

  -- Required fields
  reference text not null,      -- Example: 'Proverbs 18:12'
  translation text not null default 'NLT',
  text text not null,           -- Full verse text

  -- Background image URL
  image_url text,

  -- Automatic timestamp
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table daily_verses enable row level security;

-- Allow public read access (safe for Bible verses)
create policy "Public read access on daily_verses"
  on daily_verses
  for select
  using (true);

-- Allow insert (for development; you can restrict later)
create policy "Allow insert for development"
  on daily_verses
  for insert
  with check (true);
```

### Fields:
- **id** - UUID primary key (auto-generated)
- **date** - Optional date for scheduled verses (e.g., 2025-12-11)
- **reference** - Bible reference (e.g., "Proverbs 18:12") - REQUIRED
- **translation** - Translation code (e.g., "NLT", "KJV") - REQUIRED, default 'NLT'
- **text** - Full verse text - REQUIRED
- **image_url** - Background image URL (optional)
- **created_at** - Timestamp when added (auto-generated)

---

## 🚀 Quick Start

### Step 1: Update pubspec.yaml
Already included in your project:
- `flutter_local_notifications: ^17.2.3`
- `timezone: ^0.9.0`
- `google_fonts: ^6.1.0`

### Step 2: Create Supabase Table
Run the SQL schema above in your Supabase console.

### Step 3: Update main.dart
```dart
import 'core/notification_service_verse.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Setup daily verse notification
  await setupDailyVerseNotification(
    notificationTime: const TimeOfDay(hour: 6, minute: 0),
    notificationHour: 6,
    notificationMinute: 0,
  );

  runApp(const MinistryApp());
}
```

### Step 4: Add Routes
```dart
routes: {
  '/verse-of-the-day': (_) => const DevotionVerseScreen(),
  '/verse': (context) {
    final verseId = ModalRoute.of(context)?.settings.arguments as String?;
    return DevotionVerseScreen(verseId: verseId);
  },
}
```

### Step 5: Add Navigation Button
```dart
ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(context, '/verse-of-the-day'),
  icon: const Icon(Icons.book),
  label: const Text('Verse of the Day'),
)
```

---

## 🎨 UI Layout

### DevotionVerseScreen
```
┌─────────────────────────┐
│  Background Image       │
│   (from verse.imageUrl) │
│                         │
│                         │
│                         │
├─────────────────────────┤
│  ┌───────────────────┐  │
│  │ Reference - Trans │  │ <- Bold, big font
│  │ "Proverbs 18:12"  │  │
│  │                   │  │
│  │ Verse text here   │  │ <- Italic, readable
│  │ with good line    │  │
│  │ spacing and       │  │
│  │ padding...        │  │
│  │                   │  │
│  │ Date: Dec 11, 2025│ │ <- Small, grey
│  └───────────────────┘  │
└─────────────────────────┘
```

### VerseOfTheDayCard (Widget)
Quick preview for home screen showing reference and truncated text.

### VerseCarousel (Widget)
Horizontal scrolling list of upcoming verses (next 7 days).

---

## 🔔 Notification Behavior

### Daily Scheduling
- Runs every morning at configured time (default: 6:00 AM)
- Uses local timezone
- Survives app restarts
- Title: "Proverbs 18:12 - NLT"
- Body: First 150 characters of verse text

### When Tapped
- Opens `DevotionVerseScreen`
- Automatically loads the tapped verse
- Payload contains verse ID for identification

---

## 🛠️ Customization

### Change Notification Time
In main.dart:
```dart
await setupDailyVerseNotification(
  notificationTime: const TimeOfDay(hour: 7, minute: 30), // 7:30 AM
  notificationHour: 7,
  notificationMinute: 30,
);
```

### Add User Preferences
Create a settings page with SharedPreferences:
```dart
Future<void> saveNotificationTime(TimeOfDay time) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('verse_time', '${time.hour}:${time.minute}');
}

Future<void> applyUserSettings() {
  // Read from SharedPreferences and update notification
  await setupDailyVerseNotification(...);
}
```

### Add More Verses
Insert into `daily_verses` table:
```sql
INSERT INTO daily_verses (reference, translation, text, image_url)
VALUES 
('John 3:16', 'KJV', 'For God so loved the world...', 'https://...'),
('Philippians 4:8', 'NLT', 'Fix your thoughts on what is true...', 'https://...');
```

### Use Different Images
Upload images to Supabase Storage and use public URLs:
```dart
// In Supabase console, set image_url to:
'https://your-bucket.supabase.co/storage/v1/object/public/images/verse1.jpg'
```

---

## 📱 Platform Setup

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS (Info.plist)
```xml
<key>UILocalNotificationTimeZoneFormat</key>
<string>HH:mm:ss z</string>
```

---

## 🧪 Testing

### Test Notification Immediately
```dart
final service = NotificationService();
await service.init();
final verse = await DailyVerseRepository().getVerseForToday();
if (verse != null) {
  await service.showTestNotification(verse: verse);
}
```

### Test Screen Directly
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const DevotionVerseScreen()),
);
```

### Test with Specific Verse
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DevotionVerseScreen(verseId: 'some-uuid'),
  ),
);
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Notifications not appearing | Check permissions in Android/iOS, verify `init()` called |
| Verse not loading | Check table has data, verify Supabase connection |
| Images not showing | Verify URLs are public, check network connection |
| Wrong timezone | Ensure `tz_data.initializeTimeZones()` is called |
| Notification time wrong | Verify TimeOfDay and system timezone are correct |

---

## 📦 Dependencies
- `supabase_flutter: ^2.5.6` ✅ Already in pubspec.yaml
- `flutter_local_notifications: ^17.2.3` ✅ Already in pubspec.yaml
- `timezone: ^0.9.0` ✅ Already in pubspec.yaml
- `google_fonts: ^6.1.0` ✅ Already in pubspec.yaml
- `intl: ^0.18.1` ✅ Already in pubspec.yaml

No additional dependencies needed!

---

## 🎯 Features Summary

✅ **Data Management**
- Supabase integration with fallback logic
- Support for scheduled or random verses
- Historical verse tracking

✅ **Notifications**
- Daily scheduling with user-configurable time
- Proper Android/iOS permissions handling
- Repeating notifications
- Timezone-aware scheduling

✅ **UI**
- Beautiful full-screen display
- Background image support
- White card panel for readability
- Loading and error states
- Responsive design

✅ **Extensibility**
- Easy to add user preferences
- Widget components for reuse
- Clean architecture separation
- Well-documented code

✅ **Quality**
- Error handling throughout
- Graceful fallbacks
- Type-safe Dart code
- Google Fonts typography
- Matches your app theme

---

## 📝 Next Steps

1. Create the `daily_verses` table in Supabase
2. Add sample verses with image URLs
3. Update `main.dart` with notification setup
4. Add routes to your navigation
5. Test notifications on device
6. Consider adding user preferences for notification time
7. Add verses to your Supabase database

---

## 📞 Support

All files are self-contained and well-documented.
Refer to `VERSE_INTEGRATION_EXAMPLES.dart` for code snippets.

Happy coding! 🎉
