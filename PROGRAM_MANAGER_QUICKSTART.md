# Program Manager - 5-Minute Quick Start

## ⚡ Get Running in 5 Minutes

### Step 1: Create Supabase Table (2 minutes)

Go to **supabase.com** → Your project → **SQL Editor** → **New Query**

Copy & paste this:

```sql
CREATE TABLE church_programs (
  id BIGSERIAL PRIMARY KEY,
  date VARCHAR(10) NOT NULL,
  activity_description TEXT NOT NULL,
  venue VARCHAR(255),
  lead VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_church_programs_date ON church_programs(date);
```

Click **Run** ✅

### Step 2: Add Dependencies (1 minute)

In terminal (from project root):

```bash
flutter pub add file_picker csv share_plus
```

Or manually add to `pubspec.yaml`:

```yaml
dependencies:
  file_picker: ^5.3.0
  csv: ^5.0.0
  share_plus: ^7.0.0
```

Then:

```bash
flutter pub get
```

### Step 3: Run the App (1 minute)

```bash
flutter run
```

Find the **Programs** tab at the bottom → Tap it!

### Step 4: Test It Out (1 minute)

**Try this:**

1. Tap **"Add Event"** button
2. Pick a date
3. Type "Christmas Celebration"
4. Type "Main Hall" for venue
5. Type "Pastor John" for lead
6. Tap **"Save Event"**

✅ Your first program is added!

**Try filtering:**

1. Type "Christmas" in the activity search
2. Programs list filters in real-time
3. Tap "Clear Filters" to reset

---

## 📍 Where Everything Is

| What | Where |
|------|-------|
| Main code | `lib/features/programs/program_manager_screen.dart` |
| Beginner guide | `PROGRAM_MANAGER_FOR_BEGINNERS.md` |
| Technical reference | `PROGRAM_MANAGER_TECHNICAL.md` |
| Database table | Supabase → `church_programs` |
| In navigation | Programs tab (9th tab) |

---

## 🎯 Key Features at a Glance

```
┌─────────────────────────────────────────┐
│         Program Manager Screen          │
├─────────────────────────────────────────┤
│ [Calendar Icon] Program Schedule        │
│  Church Programs · Events · Activities  │
│                                         │
│ [Import CSV] [Export] [+ Add Event]   │
├─────────────────────────────────────────┤
│ Filter Programs            [Clear]      │
│ [Search] [From] [To]                   │
│ [Venue ▼] [Lead ▼]                     │
├─────────────────────────────────────────┤
│ Date  | Activity      | Venue | [Edit] │
│────────────────────────────────────────│
│ 12/25 | Christmas Cel | Main  | ✏️ 🗑   │
│ Wed   | Celebration   | Hall  |        │
├─────────────────────────────────────────┤
```

---

## 💡 Code Structure (Simplified)

**One file:** `program_manager_screen.dart`

Contains:

1. **Program class** — Data model
   - Fields: id, date, activity, venue, lead
   - Methods: fromMap(), toMap()

2. **ProgramManagerScreenState** — Main logic
   - Load programs from Supabase
   - Save/update/delete
   - Filter & search
   - CSV import/export

3. **UI Widgets** — Display
   - Header card with buttons
   - Filter card
   - Program list
   - Editor modal

---

## 🔄 Common Workflows

### Add a New Program

```
Tap "Add Event"
    ↓
Fill in form (date + activity required)
    ↓
Tap "Save Event"
    ↓
Program added to Supabase
    ↓
List refreshes automatically
```

### Edit Existing

```
Click pencil icon on a row
    ↓
Editor modal opens with current values
    ↓
Change fields
    ↓
Tap "Save Event"
    ↓
Supabase updates
    ↓
List refreshes
```

### Delete

```
Click trash icon
    ↓
Confirmation dialog appears
    ↓
Confirm deletion
    ↓
Supabase deletes
    ↓
List refreshes
```

### Filter by Activity

```
Type "Christmas" in search box
    ↓
List filters instantly
    ↓
Only shows programs with "Christmas" in name
```

### Filter by Date Range

```
Tap "From date" → pick a date
    ↓
Tap "To date" → pick a date
    ↓
List shows only programs in that range
    ↓
Can combine with other filters
```

---

## 🛠️ Customization Examples

### Change Header Color

Find `_buildHeaderCard()` method:

```dart
gradient: LinearGradient(
  colors: [
    Colors.blue.shade400,      // ← Change this
    Colors.blue.shade300,      // ← And this
  ],
),
```

Change to:

```dart
colors: [
  Colors.purple.shade400,
  Colors.purple.shade300,
],
```

### Change Button Colors

```dart
// Import button
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green.shade600,  // ← Change
  ),
)
```

### Add More Text to Activity Icon

In `_getActivityIcon()`:

```dart
if (lower.contains('worship')) {
  return Icons.music_note;
} else if (lower.contains('meeting')) {  // ← Add another
  return Icons.briefcase;
}
```

### Change Grid Layout

In `_buildScheduleCard()`, the Row has these widths:

```dart
SizedBox(width: 80, child: Text('Date')),      // Date column
Expanded(...),                                   // Activity (takes rest)
SizedBox(width: 120, child: Text('Venue')),    // Venue column
SizedBox(width: 80, ...),                      // Edit/Delete
```

Increase any width to give more space.

---

## ✅ Common Issues & Fixes

| Problem | Solution |
|---------|----------|
| "No programs found" | Make sure `church_programs` table exists in Supabase |
| Can't add programs | Check Supabase permissions (RLS policies) |
| Import/Export buttons don't work | Add packages: `flutter pub add file_picker csv share_plus` |
| Filters not working | Make sure you're typing in the right field |
| Editor modal doesn't appear | Check that `_isEditing` state is set to true |
| Crashes when deleting | Make sure id exists in database |

---

## 🧪 Test Scenarios

**Scenario 1: Add & Edit**
1. Add program: "Dec 25, Christmas, Main Hall, Pastor John"
2. Edit it: Change to "Dec 26, Christmas Breakfast"
3. Verify changes saved ✅

**Scenario 2: Filter**
1. Add 3 programs with different venues
2. Select venue filter
3. List should show only that venue ✅

**Scenario 3: Delete**
1. Add a test program
2. Click delete
3. Confirm deletion
4. Should disappear from list ✅

---

## 📚 Learn More

**Beginner-friendly explanation:**
→ Read `PROGRAM_MANAGER_FOR_BEGINNERS.md`

**Technical deep-dive:**
→ Read `PROGRAM_MANAGER_TECHNICAL.md`

**Source code:**
→ See `lib/features/programs/program_manager_screen.dart`

---

## 🎉 You're Ready!

You now have a full church program management system running in Flutter!

**Next steps:**

1. ✅ Try adding your first program
2. ✅ Test filtering
3. ✅ Read the beginner guide to understand the code
4. ✅ Customize colors/fields as needed
5. ✅ Implement CSV import (once packages are added)

Happy coding! 🚀
