# Program Manager - Setup & Technical Reference

## 🚀 Quick Setup

### 1. Database Table Setup

Create this table in your Supabase dashboard:

```sql
-- Create church_programs table
CREATE TABLE church_programs (
  id BIGSERIAL PRIMARY KEY,
  date VARCHAR(10) NOT NULL,  -- YYYY-MM-DD format
  activity_description TEXT NOT NULL,
  venue VARCHAR(255),
  lead VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index on date for faster queries
CREATE INDEX idx_church_programs_date ON church_programs(date);
```

**Step-by-step in Supabase dashboard:**

1. Go to SQL Editor
2. Click "New Query"
3. Paste the SQL above
4. Click "Run"
5. You should see "Success" message

### 2. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  # ... existing dependencies ...
  file_picker: ^5.3.0      # For CSV import
  csv: ^5.0.0              # For CSV parsing
  share_plus: ^7.0.0       # For CSV export
```

**To add:**

```bash
flutter pub add file_picker csv share_plus
```

### 3. Grant Supabase Permissions

In Supabase dashboard, go to **Authentication > Policies**:

```sql
-- Allow anyone to read church_programs
CREATE POLICY "Enable read access for all users" ON "public"."church_programs"
  AS PERMISSIVE FOR SELECT
  USING (true);

-- Allow authenticated users to insert/update/delete
CREATE POLICY "Enable all access for authenticated users" ON "public"."church_programs"
  AS PERMISSIVE FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users" ON "public"."church_programs"
  AS PERMISSIVE FOR UPDATE
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for authenticated users" ON "public"."church_programs"
  AS PERMISSIVE FOR DELETE
  USING (auth.role() = 'authenticated');
```

---

## 📁 File Structure

```
lib/
  features/
    programs/
      program_manager_screen.dart       ← Main screen (all code in one file)
```

The entire Program Manager is in **one Dart file** for simplicity. Later, you can split it into:

```
lib/
  features/
    programs/
      program_manager_screen.dart       ← Main screen
      models/
        program.dart                    ← Program class
      services/
        program_service.dart            ← Supabase calls
      widgets/
        program_list.dart
        program_editor.dart
        filter_card.dart
```

But for now, one file keeps it simple!

---

## 🔌 Integration with main.dart

The Program Manager is already integrated:

```dart
// In main.dart
import 'features/programs/program_manager_screen.dart';

// In screens list:
final screens = [
  // ... other screens ...
  const ProgramManagerScreen(),  ← Added here
];

// In bottom nav:
BottomNavigationBarItem(
  icon: Icon(Icons.event),
  label: 'Programs',
),
```

It appears as the **Programs** tab in your bottom navigation.

---

## 🎯 Data Model Reference

### Program Class

```dart
class Program {
  final dynamic id;                    // int or String
  final String date;                   // YYYY-MM-DD
  final String activityDescription;
  final String? venue;
  final String? lead;
}
```

**Creating a Program:**

```dart
final program = Program(
  id: 1,
  date: '2025-12-25',
  activityDescription: 'Christmas Celebration',
  venue: 'Main Hall',
  lead: 'Pastor John',
);
```

**From Supabase:**

```dart
final program = Program.fromMap(supabaseRow);
```

**To Supabase:**

```dart
final map = program.toMap();
// => {'date': '2025-12-25', 'activity_description': '...', ...}
```

---

## 📊 State Management

### State Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `_programs` | `List<Program>` | All programs from database |
| `_loading` | `bool` | Is loading? (show spinner) |
| `_importing` | `bool` | Is importing CSV? |
| `_filterActivity` | `String` | Search text |
| `_filterVenue` | `String` | Selected venue filter |
| `_filterLead` | `String` | Selected lead filter |
| `_filterStartDate` | `String` | From date (YYYY-MM-DD) |
| `_filterEndDate` | `String` | To date (YYYY-MM-DD) |
| `_isEditing` | `bool` | Is editor modal open? |
| `_editingProgram` | `Program?` | Which program being edited |

### Computed Values (Getters)

```dart
_uniqueVenues      // List<String> of all venue names
_uniqueLeads       // List<String> of all lead names
_filteredPrograms  // List<Program> after applying all filters
_isFilterActive    // bool: are any filters applied?
```

---

## 🔄 API Methods

### Fetch Programs

```dart
Future<void> _fetchPrograms() async {
  setState(() => _loading = true);
  try {
    final response = await _supabase
        .from('church_programs')
        .select('*')
        .order('date', ascending: true);
    
    final programs = (response as List)
        .map((p) => Program.fromMap(p))
        .toList();
    
    setState(() => _programs = programs);
  } catch (e) {
    _showError('Failed to load programs: $e');
  } finally {
    setState(() => _loading = false);
  }
}
```

**When called:**
- On screen load (in `initState()`)
- After saving a program
- After deleting a program
- After importing CSV

### Save Program (Insert or Update)

```dart
Future<void> _saveProgram() async {
  // Validate inputs
  if (date.isEmpty || activity.isEmpty) {
    _showError('Date and Activity required');
    return;
  }

  try {
    final program = Program(
      id: _editingProgram?.id,
      date: date,
      activityDescription: activity,
      venue: venue.isEmpty ? null : venue,
      lead: lead.isEmpty ? null : lead,
    );

    if (_editingProgram != null) {
      // UPDATE
      await _supabase
          .from('church_programs')
          .update(program.toMap())
          .eq('id', _editingProgram!.id);
    } else {
      // INSERT
      await _supabase
          .from('church_programs')
          .insert(program.toMap());
    }

    _closeEditor();
    _fetchPrograms();
  } catch (e) {
    _showError('Error saving program: $e');
  }
}
```

### Delete Program

```dart
Future<void> _deleteProgram(Program program) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete ${program.activityDescription}?'),
      // ... buttons ...
    ),
  );

  if (confirmed != true) return;

  try {
    await _supabase
        .from('church_programs')
        .delete()
        .eq('id', program.id);
    
    _fetchPrograms();
  } catch (e) {
    _showError('Error deleting: $e');
  }
}
```

---

## 🔍 Filtering Logic

All filters are applied via the `_filteredPrograms` getter:

```dart
List<Program> get _filteredPrograms {
  return _programs.where((p) {
    // Activity text search (case-insensitive)
    final matchActivity = p.activityDescription
        .toLowerCase()
        .contains(_filterActivity.toLowerCase());
    
    // Venue dropdown (or empty = all)
    final matchVenue = _filterVenue.isEmpty || p.venue == _filterVenue;
    
    // Lead dropdown (or empty = all)
    final matchLead = _filterLead.isEmpty || p.lead == _filterLead;
    
    // Date range (or empty = no limit)
    final matchStart = _filterStartDate.isEmpty || 
                       p.date.compareTo(_filterStartDate) >= 0;
    final matchEnd = _filterEndDate.isEmpty || 
                     p.date.compareTo(_filterEndDate) <= 0;

    // Must match ALL conditions
    return matchActivity && matchVenue && matchLead && 
           matchStart && matchEnd;
  }).toList();
}
```

**Clear filters:**

```dart
void _clearFilters() {
  setState(() {
    _filterActivity = '';
    _filterVenue = '';
    _filterLead = '';
    _filterStartDate = '';
    _filterEndDate = '';
    _filterActivityController.clear();
  });
}
```

---

## 📤 CSV Import/Export Skeleton

### CSV Import (TODO: Complete with file_picker & csv packages)

```dart
Future<void> _importCSV() async {
  // TODO: Use file_picker to select .csv file
  // TODO: Parse with csv package
  // TODO: Find header row (contains "DATE" and "ACTIVITIES")
  // TODO: For each row, call _parseFlexibleDate()
  // TODO: Insert valid rows in batches of 50
  // TODO: Show success message
  // TODO: Reload programs
}
```

**Helper: Parse flexible date**

```dart
String? _parseFlexibleDate(String dateStr) {
  if (dateStr.trim().isEmpty) return null;
  
  final str = dateStr.replaceAll('"', '').trim().toUpperCase();
  
  if (str == 'TBD' || str == 'DATE') return null;
  
  try {
    // Handle "Dec 1 to Dec 3, 2025" → take first part
    String workingStr = str;
    if (str.contains(' TO ')) {
      workingStr = str.split(' TO ')[0].trim();
      // If year in second part but not first, append it
      if (!workingStr.contains(RegExp(r'\d{4}')) &&
          str.contains(RegExp(r'\d{4}'))) {
        final yearMatch = RegExp(r'(\d{4})').firstMatch(str);
        if (yearMatch != null) {
          workingStr = '$workingStr, ${yearMatch.group(1)}';
        }
      }
    }
    
    // Try multiple date formats
    final formats = [
      'MMM d, yyyy',
      'MMM d yyyy',
      'M/d/yyyy',
      'yyyy-MM-dd',
      'MMMM d, yyyy',
    ];
    
    for (final format in formats) {
      try {
        final parsed = DateFormat(format).parse(workingStr);
        return parsed.toIso8601String().split('T')[0];
      } catch (_) {
        continue;
      }
    }
    
    return null;
  } catch (_) {
    return null;
  }
}
```

### CSV Export (TODO: Complete with share_plus)

```dart
Future<void> _exportCSV() async {
  try {
    final buffer = StringBuffer();
    buffer.writeln('DATE,ACTIVITIES-DESCRIPTION,VENUE,LEAD');

    for (final program in _filteredPrograms) {
      final venue = program.venue ?? '';
      final lead = program.lead ?? '';
      buffer.writeln(
        '${program.date},"${program.activityDescription}",$venue,$lead',
      );
    }

    // TODO: Use share_plus to share the CSV file
    // TODO: Or save to file and open file manager
  } catch (e) {
    _showError('Export failed: $e');
  }
}
```

---

## 🎨 UI Components

### Header Card

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade400, Colors.blue.shade300],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  padding: const EdgeInsets.all(20),
  child: Column(...)
)
```

**To customize:**
- Change gradient colors
- Change border radius (currently 20)
- Change padding (currently 20)

### Filter Card

```dart
Card(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(...)
  )
)
```

### Program List Item

```dart
Row(
  children: [
    // Date block (70 wide)
    // Activity with icon (expanded)
    // Venue with location icon (120 wide)
    // Edit/Delete buttons (80 wide)
  ],
)
```

---

## 🔧 Common Modifications

### Add a "Notes" Field

1. **Update Program class:**

```dart
class Program {
  // ... existing fields ...
  final String? notes;
  
  Program({
    // ... existing params ...
    this.notes,
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

2. **Update database:**

```sql
ALTER TABLE church_programs ADD COLUMN notes TEXT;
```

3. **Update editor form:**

```dart
TextField(
  minLines: 2,
  maxLines: 4,
  decoration: InputDecoration(
    labelText: 'Notes',
    border: OutlineInputBorder(),
  ),
  controller: _notesController,
)
```

### Change Color Scheme

Primary colors are in `_buildHeaderCard()` and action buttons:

```dart
// Header gradient
colors: [Colors.blue.shade400, Colors.blue.shade300]

// Import button
backgroundColor: Colors.green.shade600

// Add button
backgroundColor: Colors.blue.shade600
```

### Add Status Field (Scheduled, Completed, Cancelled)

1. Add to Program class
2. Add dropdown in filters
3. Add to editor with radio buttons
4. Filter by status in `_filteredPrograms`

---

## ✅ Testing Checklist

- [ ] App builds without errors
- [ ] Can view list of programs (if table exists)
- [ ] Can add new program
- [ ] Can edit existing program
- [ ] Can delete program (with confirmation)
- [ ] Filter by activity (search)
- [ ] Filter by venue (dropdown)
- [ ] Filter by lead (dropdown)
- [ ] Filter by date range
- [ ] Clear filters button works
- [ ] Empty state displays when no programs
- [ ] Loading spinner shows while loading
- [ ] Error messages display on failures
- [ ] Editor modal opens/closes properly
- [ ] Date picker works in editor
- [ ] Date picker works in filters

---

## 🐛 Troubleshooting

### "No programs found" even though I added some

**Check:**
- Is the `church_programs` table created in Supabase?
- Are row permissions set correctly? (Check RLS policies)
- Try pulling down the "Programs" tab to refresh
- Check the console for error messages

### Edit dialog doesn't open

**Check:**
- `_openEditor()` is being called
- `setState()` is called with `_isEditing = true`
- `endDrawer` property is set correctly

### Filter doesn't work

**Check:**
- `_filterActivity` value is being set
- `setState()` is called after filter change
- `_filteredPrograms` getter is being used in build

### Import button shows "Add packages" message

**Need to:**
```bash
flutter pub add file_picker csv share_plus
```

Then implement the `_importCSV()` method.

---

## 📚 Related Files

- `lib/features/programs/program_manager_screen.dart` — Main implementation
- `lib/main.dart` — Navigation integration
- `lib/secrets.dart` — Supabase credentials
- This file — Technical reference

---

## 🎓 Learning Resources

**Key Flutter Concepts Used:**

- **StatefulWidget** — Manages state
- **Future & async/await** — Handle asynchronous operations
- **ListView.builder** — Efficient list rendering
- **FutureBuilder** — Wait for async data
- **TextField & DropdownButtonFormField** — Form inputs
- **showDialog** — Confirmation dialogs
- **Drawer** — Slide-out panel for editor
- **GridView** — Two-column layout (optional)
- **Getters** — Computed properties
- **List.where()** — Filtering collections

**Packages Used:**

- `intl` — Date formatting
- `supabase_flutter` — Database access
- (TODO) `file_picker` — Select files
- (TODO) `csv` — Parse CSV
- (TODO) `share_plus` — Share files

---

**Last Updated:** December 2025
**Status:** Production-ready with TODO items for CSV import/export
