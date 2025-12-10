# Program Manager Screen - Beginner's Guide

Welcome! This guide explains the Church Program Manager screen from the ground up. You're new to coding, so we'll take it slow and explain every piece.

## 📚 Table of Contents

1. [What is the Program Manager?](#what-is-the-program-manager)
2. [The Big Picture](#the-big-picture)
3. [Understanding the Data Model](#understanding-the-data-model)
4. [Key Concepts Explained](#key-concepts-explained)
5. [How the Code Works](#how-the-code-works)
6. [Database Connection](#database-connection)
7. [User Actions & Data Flow](#user-actions--data-flow)
8. [Customization Guide](#customization-guide)
9. [Common Tasks](#common-tasks)

---

## What is the Program Manager?

The **Program Manager Screen** is a tool for church leaders to:

- 📅 **Manage events** — Add, edit, and delete church programs and events
- 🔍 **Search & filter** — Find programs by activity, venue, lead person, or date range
- 📤 **Import/Export** — Bulk import programs from CSV files, export your schedule
- 🎯 **View at a glance** — See all programs organized by date with color-coded activities

Think of it like a **calendar + task manager** combined, but specifically for church ministry activities.

---

## The Big Picture

Here's the flow of how the Program Manager works:

```
┌─────────────────────────────────────────────────────────┐
│                 Supabase Database                        │
│           (Table: church_programs)                       │
│                                                          │
│  Stores: date, activity_description, venue, lead        │
└──────────────────────▲──────────────────────────────────┘
                       │
                    ↓ ↑
        ┌──────────────────────────────┐
        │   ProgramManagerScreen       │
        │   (Flutter StatefulWidget)   │
        │                              │
        │  Handles:                    │
        │  - Loading data              │
        │  - Filtering programs        │
        │  - Editing/saving            │
        │  - Deleting                  │
        │  - CSV import/export         │
        └──────────────────────────────┘
                    ↓ ↑
        ┌──────────────────────────────┐
        │        User Interface        │
        │                              │
        │  Shows: header card,         │
        │         filters,             │
        │         program list,        │
        │         editor modal         │
        └──────────────────────────────┘
```

**The flow:**

1. When you open the screen, it **loads** all programs from Supabase
2. You can **filter** or **search** to find specific programs
3. You can **tap a program** to edit it, or tap "Add Event" to create new
4. Changes are **saved to Supabase** and the list **reloads** automatically
5. You can **import** programs from a CSV file or **export** the current list

---

## Understanding the Data Model

The `Program` class is like a **template** for what information we store about each event.

### The Program Class

```dart
class Program {
  final dynamic id;                    // Unique identifier
  final String date;                   // YYYY-MM-DD format
  final String activityDescription;    // What is the event?
  final String? venue;                 // Where? (optional)
  final String? lead;                  // Who is leading? (optional)
}
```

**What each field means:**

| Field | Type | Example | Required? |
|-------|------|---------|-----------|
| `id` | String/int | `1` or `"abc-123"` | ✅ Yes (from Supabase) |
| `date` | String | `"2025-12-25"` | ✅ Yes |
| `activityDescription` | String | `"Christmas Celebration"` | ✅ Yes |
| `venue` | String? | `"Main Hall"` | ❌ No |
| `lead` | String? | `"Pastor John"` | ❌ No |

The **?** (question mark) means "optional" — it can be `null` (empty) or have a value.

### fromMap() - Converting Supabase data to Program

When you fetch data from Supabase, it comes back as a **Map** (like a dictionary):

```dart
{
  'id': 1,
  'date': '2025-12-25',
  'activity_description': 'Christmas Celebration',
  'venue': 'Main Hall',
  'lead': 'Pastor John'
}
```

The `fromMap()` method **converts** this map into a `Program` object:

```dart
factory Program.fromMap(Map<String, dynamic> map) {
  return Program(
    id: map['id'],
    date: map['date'] ?? '',
    activityDescription: map['activity_description'] ?? '',
    venue: map['venue'],
    lead: map['lead'],
  );
}
```

**How it works:**
- `map['id']` — Get the value associated with key `'id'`
- `map['date'] ?? ''` — Get the date, OR if it's null, use empty string `''`
- The `??` operator means "if the left side is null, use the right side"

### toMap() - Converting Program back to database format

When you **save** a program to Supabase, you need to convert it back to a map:

```dart
Map<String, dynamic> toMap() {
  return {
    'date': date,
    'activity_description': activityDescription,
    'venue': venue,
    'lead': lead,
  };
}
```

**Note:** We don't include `id` in `toMap()` because Supabase generates the ID automatically.

---

## Key Concepts Explained

### 1. State Variables

The `_ProgramManagerScreenState` class has several **state variables** that track information:

```dart
List<Program> _programs = [];              // All programs from database
bool _loading = true;                      // Are we loading?
bool _importing = false;                   // Are we importing CSV?

String _filterActivity = '';               // What activity to search for?
String _filterVenue = '';                  // Which venue to filter?
String _filterLead = '';                   // Which lead to filter?
String _filterStartDate = '';              // Filter from this date
String _filterEndDate = '';                // Filter until this date

bool _isEditing = false;                   // Is editor modal open?
Program? _editingProgram;                  // Which program are we editing?
```

**Why track these?**

When any of these change, the UI **rebuilds** to reflect the new state. For example:
- When `_loading` changes from `true` to `false`, the spinner disappears and data appears
- When `_filterActivity` changes, the list automatically filters to show matching programs

### 2. Async/Await & Futures

Many operations in Flutter are **asynchronous** — they take time (like loading from database).

```dart
Future<void> _fetchPrograms() async {
  try {
    setState(() => _loading = true);
    
    final response = await _supabase
        .from('church_programs')
        .select('*')
        .order('date', ascending: true);
    
    // Convert response to Program objects
    final programs = (response as List)
        .map((p) => Program.fromMap(p))
        .toList();
    
    setState(() => _programs = programs);
  } catch (e) {
    // Show error message
  } finally {
    setState(() => _loading = false);
  }
}
```

**Breaking it down:**

- `Future<void>` — This function will return nothing (void) eventually
- `async` — This function can use `await`
- `await` — "Wait for this to complete before moving on"
- `try { ... } catch { ... } finally { ... }` — Handle errors gracefully

**The flow:**
1. Set `_loading = true` (show spinner)
2. **Await** the database query to complete
3. **Convert** the response to Program objects
4. Save to `_programs` and update UI
5. If error, show error message
6. Always set `_loading = false` (hide spinner)

### 3. Getters - Computed Values

**Getters** are like methods, but they look like properties:

```dart
List<String> get _uniqueVenues {
  return _programs
      .where((p) => p.venue != null && p.venue!.isNotEmpty)
      .map((p) => p.venue!)
      .toSet()
      .toList()
      ..sort();
}
```

This getter extracts all **unique venues** from the programs:

- `.where(...)` — Keep only programs that have a venue
- `.map(...)` — Extract just the venue string from each
- `.toSet()` — Remove duplicates
- `.toList()` — Convert back to a list
- `..sort()` — Sort alphabetically

**Usage:**

```dart
final venues = _uniqueVenues;  // Looks like accessing a property
```

### 4. Filtered List

```dart
List<Program> get _filteredPrograms {
  return _programs.where((p) {
    final matchActivity = p.activityDescription
        .toLowerCase()
        .contains(_filterActivity.toLowerCase());
    final matchVenue = _filterVenue.isEmpty || p.venue == _filterVenue;
    final matchLead = _filterLead.isEmpty || p.lead == _filterLead;
    final matchStart = _filterStartDate.isEmpty || 
                       p.date.compareTo(_filterStartDate) >= 0;
    final matchEnd = _filterEndDate.isEmpty || 
                     p.date.compareTo(_filterEndDate) <= 0;

    return matchActivity && matchVenue && matchLead && 
           matchStart && matchEnd;
  }).toList();
}
```

**What it does:**

For each program, check if it matches **all** active filters:

- **Activity match** — Does the description contain the search text?
- **Venue match** — Is no venue filter set, OR does it match?
- **Lead match** — Is no lead filter set, OR does it match?
- **Date range match** — Is the date within the selected range?

Only **return** programs that match all conditions.

---

## How the Code Works

### Load Programs on Startup

When the screen first appears:

```dart
@override
void initState() {
  super.initState();
  _supabase = Supabase.instance.client;
  // ... initialize text controllers ...
  _fetchPrograms();  // Load data
}
```

`initState()` is called **once** when the widget is created. It:
1. Gets a reference to Supabase
2. Creates text field controllers
3. Calls `_fetchPrograms()` to load data

### Saving a Program

```dart
Future<void> _saveProgram() async {
  // 1. Validate inputs
  if (date.isEmpty || activity.isEmpty) {
    // Show error
    return;
  }

  try {
    final program = Program(
      id: _editingProgram?.id,  // Use existing ID if editing
      date: date,
      activityDescription: activity,
      venue: venue.isEmpty ? null : venue,
      lead: lead.isEmpty ? null : lead,
    );

    // 2. Insert or update
    if (_editingProgram != null) {
      // UPDATE existing
      await _supabase
          .from('church_programs')
          .update(program.toMap())
          .eq('id', _editingProgram!.id);
    } else {
      // INSERT new
      await _supabase
          .from('church_programs')
          .insert(program.toMap());
    }

    // 3. Reload and close
    _closeEditor();
    _fetchPrograms();
  } catch (e) {
    // Show error
  }
}
```

**The flow:**

1. **Validate** — Make sure required fields aren't empty
2. **Create Program object** — With all the field values
3. **Check if editing** — If `_editingProgram` is set, we're updating; otherwise inserting
4. **Save to Supabase** — Either `.update()` or `.insert()`
5. **Reload** — Close editor and fetch all programs again

### Deleting a Program

```dart
Future<void> _deleteProgram(Program program) async {
  // 1. Confirm with user
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Program?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm != true) return;  // User cancelled

  try {
    // 2. Delete from database
    await _supabase
        .from('church_programs')
        .delete()
        .eq('id', program.id);

    // 3. Reload
    _fetchPrograms();
  } catch (e) {
    // Show error
  }
}
```

**The flow:**

1. Show a confirmation dialog
2. If user confirmed, delete from Supabase
3. Reload the program list

---

## Database Connection

### Setting Up Supabase

The code uses **Supabase**, which is a backend database service.

```dart
late final SupabaseClient _supabase;

@override
void initState() {
  super.initState();
  _supabase = Supabase.instance.client;  // Get Supabase client
}
```

`Supabase.instance.client` is initialized in `main.dart`:

```dart
await Supabase.initialize(
  url: supabaseUrl,      // Your database URL
  anonKey: supabaseAnonKey,  // Your API key
);
```

These keys are stored in `lib/secrets.dart`.

### Database Operations

**Fetch (Read):**
```dart
final response = await _supabase
    .from('church_programs')
    .select('*')                    // Get all columns
    .order('date', ascending: true); // Sort by date
```

**Insert (Create):**
```dart
await _supabase
    .from('church_programs')
    .insert(program.toMap());
```

**Update:**
```dart
await _supabase
    .from('church_programs')
    .update(program.toMap())
    .eq('id', program.id);  // Where id matches
```

**Delete:**
```dart
await _supabase
    .from('church_programs')
    .delete()
    .eq('id', program.id);  // Where id matches
```

---

## User Actions & Data Flow

### When User Taps "Add Event"

```
User taps "Add Event" button
        ↓
_openEditor() called with no program
        ↓
_isEditing = true
_editingProgram = null
_dateController.clear()  (clear all fields)
        ↓
setState() called
        ↓
UI rebuilds with editor drawer visible
        ↓
User fills in form and taps "Save Event"
        ↓
_saveProgram() called
        ↓
Validates inputs (not empty)
        ↓
Creates new Program object
        ↓
Calls await _supabase.from('church_programs').insert(...)
        ↓
_closeEditor() called
        ↓
_fetchPrograms() reloads from database
        ↓
UI updates with new program in list
```

### When User Filters by Venue

```
User selects "Main Hall" from Venue dropdown
        ↓
_filterVenue = "Main Hall"
        ↓
setState() called
        ↓
_filteredPrograms getter recalculates
        ↓
Returns only programs where venue == "Main Hall"
        ↓
UI rebuilds showing only matching programs
```

### When User Imports CSV

```
User taps "Import CSV" button
        ↓
_importCSV() called
        ↓
File picker opens (select .csv file)
        ↓
CSV parser reads file
        ↓
Look through first ~25 rows for header
        ↓
Extract header row indices (DATE, DESCRIPTION, etc)
        ↓
For each row: parse date, get description, venue, lead
        ↓
Skip invalid rows (no date or description)
        ↓
Build list of Program objects
        ↓
Insert in batches of ~50 to Supabase
        ↓
_importing = false
        ↓
Show "Successfully imported X programs"
        ↓
_fetchPrograms() reloads
```

---

## Customization Guide

### Change Colors

The header gradient and accent colors are defined in `_buildHeaderCard()`:

```dart
// Current: Blue gradient
gradient: LinearGradient(
  colors: [
    Colors.blue.shade400,  // Light blue
    Colors.blue.shade300,  // Lighter blue
  ],
),
```

**To change to purple:**

```dart
colors: [
  Colors.purple.shade400,
  Colors.purple.shade300,
],
```

**To change button colors:**

```dart
// Import CSV button
backgroundColor: Colors.green.shade600,

// To change to teal:
backgroundColor: Colors.teal.shade600,
```

### Add More Fields

To add a new field (e.g., `notes`):

1. **Update the `Program` class:**

```dart
class Program {
  // ... existing fields ...
  final String? notes;  // Add this
  
  Program({
    // ... existing parameters ...
    this.notes,  // Add this
  });
  
  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      // ... existing ...
      notes: map['notes'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      // ... existing ...
      'notes': notes,
    };
  }
}
```

2. **Add to editor form:**

```dart
// In _buildEditorDrawer()
TextField(
  controller: TextEditingController(),  // Create new controller
  decoration: InputDecoration(
    labelText: 'Notes',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
),
```

3. **Add to table display:**

```dart
// In _buildProgramRow()
if (program.notes != null)
  Text('Notes: ${program.notes}')
```

### Change Activity Icons

The `_getActivityIcon()` method maps keywords to icons:

```dart
IconData _getActivityIcon(String description) {
  final lower = description.toLowerCase();

  if (lower.contains('worship')) {
    return Icons.music_note;  // ← Change this icon
  } else if (lower.contains('meeting')) {
    return Icons.briefcase;  // ← Or this
  }
  // ... etc
}
```

**Available Material Icons:**

- `Icons.music_note` — Music
- `Icons.briefcase` — Work
- `Icons.favorite` — Heart/Love
- `Icons.school` — Education
- `Icons.people` — Group
- `Icons.local_dining` — Food
- `Icons.mic` — Microphone
- `Icons.calendar_today` — Calendar

---

## Common Tasks

### How to add a "Status" field?

1. Add to `Program` class
2. Add dropdown in filter card
3. Add to editor form
4. Update `toMap()` and `fromMap()`

### How to make programs repeating (weekly, monthly)?

1. Add `recurrence` field to Program
2. When saving, generate multiple Program entries
3. Use date math to calculate repeat dates

### How to add email notifications?

1. Add a `_notificationService` in `initState()`
2. After `_fetchPrograms()`, check for upcoming events
3. Call notification service for events in next 24 hours

### How to add user permissions?

1. Fetch current user from Supabase auth
2. In `_saveProgram()`, add `created_by` field
3. In `_deleteProgram()`, check if user is the creator
4. Only allow edit/delete if user matches

---

## Summary

You've learned:

✅ How the Program Manager works at a high level
✅ What the `Program` data model does
✅ How state variables track app state
✅ How to fetch, save, and delete from Supabase
✅ How filters work
✅ How to customize colors, fields, and behavior

The code is designed to be **modular** — each method does one thing well. If you want to add features, look for similar examples in the code and follow the same pattern!

**Next steps:**

1. **Run the app** — `flutter run`
2. **Create the `church_programs` table** in Supabase (see SETUP.md)
3. **Test adding/editing programs** through the UI
4. **Try importing a CSV** file (once file_picker is added)
5. **Customize colors/fields** to match your needs

Happy coding! 🎉
