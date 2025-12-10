# Program Manager - Visual Guide & Reference

## 🎨 Screen Layout

### Full Screen View

```
╔══════════════════════════════════════════════════════════╗
║                 Program Manager Screen                   ║
╠══════════════════════════════════════════════════════════╣
║  📅 Program Schedule                                     ║
║  Church Programs · Events · Ministry Activities          ║
║                                                          ║
║  [Import CSV]  [Export]  [+ Add Event]                  ║
╠══════════════════════════════════════════════════════════╣
║  🔍 Filter Programs                    [Clear Filters]   ║
║                                                          ║
║  Search activity...           📅 [From Date]            ║
║  📅 [To Date]                                           ║
║                                                          ║
║  [Select Venue ▼]  [Select Lead ▼]                      ║
╠══════════════════════════════════════════════════════════╣
║  Schedule                                                ║
║  ─────────────────────────────────────────────────────── ║
║  Date  │  Activity         │  Venue    │  Edit │ Delete  ║
║  ─────────────────────────────────────────────────────── ║
║  12/25 │ 🎵 Christmas      │ Main Hall │  ✏️   │  🗑     ║
║  Wed   │ Celebration       │           │       │         ║
║        │ Lead: Pastor John │           │       │         ║
║  ─────────────────────────────────────────────────────── ║
║  12/26 │ 🍽️ Christmas      │ Fellowship│  ✏️   │  🗑     ║
║  Thu   │ Breakfast         │ Hall      │       │         ║
║        │ Lead: Sister Mary │           │       │         ║
║  ─────────────────────────────────────────────────────── ║
║  01/03 │ 📖 Bible Study    │ Library   │  ✏️   │  🗑     ║
║  Sun   │                   │           │       │         ║
║        │ Lead: Deacon Mike │           │       │         ║
║  ─────────────────────────────────────────────────────── ║
╚══════════════════════════════════════════════════════════╝
```

---

## 🎭 Component Breakdown

### 1. Header Card

```
┌─────────────────────────────────────────┐
│                                         │
│ 📅 Program Schedule                    │
│ Church Programs · Events · Activities  │
│                                        │
│ [Import] [Export] [+ Add Event]        │
│                                         │
└─────────────────────────────────────────┘
 ↑                                         ↑
 Blue gradient background            White text
 20pt padding on all sides            24pt border radius
```

**Colors:**
- Gradient: `Colors.blue.shade400` → `Colors.blue.shade300`
- Text: White
- Border radius: 24pt
- Padding: 20pt
- Elevation: No shadow needed (gradient provides depth)

**Buttons:**
- Import CSV: Green (`Colors.green.shade600`)
- Export: White outline
- Add Event: Blue (`Colors.blue.shade600`)
- Border radius: 20pt (pill shape)

### 2. Filter Card

```
┌──────────────────────────────────────────┐
│ 🔍 Filter Programs    [Clear Filters]   │
├──────────────────────────────────────────┤
│                                          │
│ [Search activity...]                     │
│                                          │
│ [📅 From] [📅 To]                       │
│                                          │
│ [Venue ▼]    [Lead ▼]                   │
│                                          │
└──────────────────────────────────────────┘
 ↑                                          ↑
 White background                    16pt padding
 Subtle shadow (elevation 2)         12pt spacing between fields
```

**Input Fields:**
- TextField: Rounded corners (12pt), border
- DropdownButton: Same styling as TextField
- Date picker: Tappable, shows date picker on tap
- Clear button: Appears only when filters active

### 3. Schedule Card

```
┌──────────────────────────────────────────────────────┐
│ Date │ Activity │ Venue │ [Edit] [Delete]           │
├──────────────────────────────────────────────────────┤
│                                                      │
│ 📦 [12] │ 🎵 Christmas      │ Main Hall │ ✏️  🗑  │
│    [25]  │    Celebration    │           │          │
│    [Wed] │    Lead: Pastor... │           │          │
│          │                   │           │          │
├──────────────────────────────────────────────────────┤
│                                                      │
│ 📦 [12] │ 🍽️ Breakfast       │ Fellowship │ ✏️  🗑 │
│    [26]  │    Celebration    │ Hall       │         │
│    [Thu] │    Lead: Sister... │           │         │
│          │                   │           │          │
└──────────────────────────────────────────────────────┘
 ↑                                                      ↑
 White background                            Each row: 12pt vertical spacing
 16pt padding                                Date box: 70pt wide
```

**Date Box:**
- Width: 70pt
- Background: Light blue (`Colors.blue.shade50`)
- Border: 1pt (`Colors.blue.shade200`)
- Border radius: 8pt
- Padding: 8pt horizontal, 6pt vertical
- Number: 18pt, bold, color: `#1F2A6B`
- Day name: 11pt, gray

**Activity Column:**
- Icon: 20pt, blue
- Title: Bold, 16pt, max 2 lines
- Lead (if present): 12pt gray, below title

**Venue Column:**
- Width: 120pt
- Icon: Location pin, 16pt
- Text: 13pt, gray

**Action Buttons:**
- Width: 80pt total
- Edit icon (blue): 18pt
- Delete icon (red): 18pt
- Each is IconButton

### 4. Editor Drawer (Right Slide-Out)

```
┌────────────────────────────────┐
│ New Ministry Event         [X]  │
├────────────────────────────────┤
│                                │
│ Date *                          │
│ [📅 2025-12-25]                │
│                                │
│ Activity Description *          │
│ [________________              │
│  ________________              │
│  ________________]             │
│                                │
│ Venue                          │
│ [📍 Main Hall]                 │
│                                │
│ Lead                           │
│ [👤 Pastor John]               │
│                                │
│ ────────────────────────────── │
│ [Cancel]  [Save Event]         │
│                                │
└────────────────────────────────┘
 ↑                                ↑
 White background            16pt padding
 Slide from right            All fields: 12pt border radius
```

**Fields:**
- Date: Read-only, shows date picker on tap
- Activity: Multi-line (3-5 lines)
- Venue: Single line, optional
- Lead: Single line, optional
- Labels: Bold, 16pt
- Asterisk (*): Indicates required field

**Buttons:**
- Cancel: Outlined style, text color
- Save Event: Filled blue (`Colors.blue.shade600`)
- Full width each

---

## 🎯 Activity Icons

| Keyword(s) | Icon | Color |
|-----------|------|-------|
| worship, choir, hymn, praise, song | 🎵 `Icons.music_note` | Blue |
| meeting, committee, board, council | 💼 `Icons.briefcase` | Blue |
| prayer, vigil, fasting | ❤️ `Icons.favorite` | Blue |
| bible, study, class, training, seminar | 📖 `Icons.school` | Blue |
| youth, fellowship, teen, children | 👥 `Icons.people` | Blue |
| food, lunch, dinner, breakfast | 🍽️ `Icons.local_dining` | Blue |
| preach, sermon | 🎤 `Icons.mic` | Blue |
| (default) | 📅 `Icons.calendar_today` | Blue |

---

## 🎨 Color Palette

### Primary Colors

| Use | Color | Hex Code | Flutter |
|-----|-------|----------|---------|
| Header gradient (light) | Light Blue | `#60A5FA` | `Colors.blue.shade400` |
| Header gradient (dark) | Blue | `#3B82F6` | `Colors.blue.shade300` |
| Import button | Green | `#16A34A` | `Colors.green.shade600` |
| Add button | Blue | `#2563EB` | `Colors.blue.shade600` |
| Date box bg | Very light blue | `#EFF6FF` | `Colors.blue.shade50` |
| Date box border | Light blue | `#BFDBFE` | `Colors.blue.shade200` |
| Delete icon | Red | `#DC2626` | `Colors.red.shade600` |
| Text/dark | Dark Blue | `#1F2A6B` | (custom) |

### Neutral Colors

| Use | Color |
|-----|-------|
| Card backgrounds | White (#FFFFFF) |
| Page background | Light lavender (#F7F5FB) |
| Text primary | Black (#000000) |
| Text secondary | Gray (#6B7280) |
| Borders | Light gray (#E5E7EB) |

---

## 📐 Spacing System

### Padding & Margins

| Element | Padding | Margin |
|---------|---------|--------|
| Page | 16pt horizontal, 20pt vertical | — |
| Header card | 20pt all sides | 0pt bottom |
| Filter card | 16pt all sides | 24pt top/bottom |
| Schedule card | 16pt all sides | 24pt top/bottom |
| Editor drawer | 16pt all sides | — |
| Form fields | 12pt between | — |
| List rows | 12pt vertical | 8pt horizontal |

### Sizing

| Element | Width | Height |
|---------|-------|--------|
| Date block | 70pt | — |
| Venue column | 120pt | — |
| Action buttons | 80pt | — |
| Activity (rest) | Expanded | — |
| Border radius (cards) | — | 16pt |
| Border radius (buttons) | — | 20pt |
| Border radius (inputs) | — | 12pt |

---

## 🔤 Typography

### Font Hierarchy

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Screen title | 28pt | Bold | White |
| Subtitle | 13pt | Regular | White (90% opacity) |
| Card title | 18pt | Bold | Black |
| Row activity | 16pt | 600 | Black |
| Row lead | 12pt | Regular | Gray |
| Labels | 14pt | Regular | Black |
| Hints | 14pt | Regular | Gray |
| Date number | 18pt | Bold | `#1F2A6B` |
| Date day | 11pt | Regular | Gray |

---

## 🔄 State Flow Diagram

### Loading State

```
Initial Load
    ↓
_loading = true
    ↓
Show spinner + "Loading schedule…"
    ↓
Fetch from Supabase
    ↓
_loading = false
    ↓
Show list
```

### Editing State

```
User taps edit
    ↓
_isEditing = true
_editingProgram = program
    ↓
Editor drawer appears
_dateController = program.date
_activityController = program.activity
    ↓
User fills form + taps Save
    ↓
_saveProgram() validates + saves
    ↓
_closeEditor()
    ↓
_isEditing = false
_editingProgram = null
    ↓
Drawer disappears
    ↓
_fetchPrograms() reloads
```

### Filter State

```
User changes filter
    ↓
_filterActivity = newValue
    ↓
setState() called
    ↓
_filteredPrograms getter recalculates
    ↓
UI rebuilds with filtered list
```

---

## 📱 Responsive Behavior

### Mobile (< 600pt)

```
┌─────────────────┐
│ Header (stacked)│
├─────────────────┤
│ Filters (stack) │
├─────────────────┤
│ List (narrow)   │
│ [Row 1]         │
│ [Row 2]         │
└─────────────────┘
```

- Buttons wrap onto multiple lines
- Column widths reduce proportionally
- Padding reduces on small screens
- Text may truncate with ellipsis (...)

### Tablet (600-1200pt)

```
┌──────────────────────────────────┐
│ Header (buttons side-by-side)    │
├──────────────────────────────────┤
│ Filters (all on one line)        │
├──────────────────────────────────┤
│ List (full width comfortable)    │
│ [Row 1]                          │
│ [Row 2]                          │
│ [Row 3]                          │
└──────────────────────────────────┘
```

- All buttons visible
- Filters laid out horizontally
- Full list visibility

### Desktop (> 1200pt)

```
┌─────────────────────────────────────────┐
│ Header (centered, buttons side-by-side) │
├─────────────────────────────────────────┤
│ Filters (multi-row, generous spacing)   │
├─────────────────────────────────────────┤
│ List (scrollable, wide columns)         │
│ [Row 1]                                 │
│ [Row 2]                                 │
│ [Row 3]                                 │
└─────────────────────────────────────────┘
```

- Maximum width container
- Generous spacing
- Multiple columns if needed

---

## ✨ Animation Details

### Button Hover (Desktop)

- Scale: 1.0 → 1.04
- Duration: 200ms
- Curve: Ease-in-out
- Mouse region tracking

### Transitions

- Editor drawer: Slide from right
- Modals: Fade in
- Lists: Build from top
- Loading spinner: Rotate continuously

---

## 🎬 User Interaction Flows

### Adding a Program

```
User taps [+ Add Event]
    ↓ _openEditor() called
    ↓ _isEditing = true
    ↓ Editor drawer slides in from right
    ↓
User fills form:
  - Tap date → date picker appears
  - Type activity (required)
  - Type venue (optional)
  - Type lead (optional)
    ↓
User taps [Save Event]
    ↓ _saveProgram() validates
    ↓ Save to Supabase
    ↓ _closeEditor()
    ↓ Editor drawer slides out
    ↓ _fetchPrograms() reloads
    ↓
Program appears in list
Success snackbar shown
```

### Filtering Programs

```
User types "Christmas" in search
    ↓ _filterActivity = "Christmas"
    ↓ setState() called
    ↓ _filteredPrograms recalculates
    ↓
UI shows only programs containing "Christmas"

User selects "Main Hall" from venue dropdown
    ↓ _filterVenue = "Main Hall"
    ↓ setState() called
    ↓ _filteredPrograms recalculates
    ↓
UI shows only programs in Main Hall (+ still containing "Christmas")

User picks date range
    ↓ _filterStartDate + _filterEndDate set
    ↓ setState() called
    ↓ _filteredPrograms recalculates
    ↓
UI shows programs matching ALL active filters

User taps [Clear Filters]
    ↓ All filter values reset to empty strings
    ↓ setState() called
    ↓ _filteredPrograms = all programs
    ↓
UI shows complete list again
```

### Deleting a Program

```
User taps trash icon
    ↓ _deleteProgram(program) called
    ↓
Confirmation dialog appears:
  "Delete Program?"
  "This action cannot be undone."
    ↓
User taps [Cancel]
    ↓ Dialog closes, nothing happens

OR

User taps [Delete]
    ↓ Dialog closes
    ↓ Delete from Supabase
    ↓ _fetchPrograms() reloads
    ↓
Program disappears from list
Success snackbar shown
```

---

## 📊 Data Display Examples

### Program Row (Full)

```
┌──────────────────────────────────────────────────┐
│ 12 │ 🎵 Christmas Celebration  │ Main  │ ✏️ 🗑  │
│ 25 │    Lead: Pastor John       │ Hall  │       │
│Wed │                            │       │       │
└──────────────────────────────────────────────────┘
 70  │                 Expanded    │  120  │  80   │
 pt  │                            │  pt   │  pt   │
```

### Program Row (Minimal)

```
┌────────────────────────────────────────┐
│ 01 │ 📖 Bible Study │ —  │ ✏️ 🗑     │
│ 03 │                │    │           │
│Sun │                │    │           │
└────────────────────────────────────────┘
```

### Empty State

```
╔═════════════════════════════════╗
║                                 ║
║            ⭕                   ║
║                                 ║
║    No programs found            ║
║                                 ║
║  Try adjusting your filters    ║
║    or search terms.            ║
║                                 ║
╚═════════════════════════════════╝
 Circle background: Light gray
 Text: Bold + subtitle
```

---

## 🎨 Theme Customization Examples

### Dark Mode Colors

```dart
// Header gradient
Colors.grey.shade800 → Colors.grey.shade900

// Text
Colors.white instead of Colors.black

// Cards
Colors.grey.shade850 instead of white

// Accents
Colors.amber.shade300 instead of blue
```

### High Contrast Mode

```dart
// Borders
1pt → 2pt

// Text
14pt → 16pt

// Spacing
16pt → 20pt

// Icons
18pt → 24pt
```

---

**Visual Reference Complete!**

Use this guide to customize colors, spacing, and layout to match your church's branding. 🎨
