# Modern Home Screen - Visual Guide

## 📱 Screen Layout (Top to Bottom)

```
┌─────────────────────────────────────┐
│                                     │
│  ╔═══════════════════════════════╗  │
│  ║  Welcome, Reverend       🏛️    ║  ← HeroHeader (Purple Gradient)
│  ║  Your Ministry Dashboard      ║
│  ║                               ║
│  ║  Today — Wed, Dec 10, 2025    ║
│  ║  Here are your tools...       ║
│  ╚═══════════════════════════════╝  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ Standing Order of the Day     │  ← StandingOrderOfTheDay
│  │                               │     (White bg, gold border)
│  │ SO 12 — Leadership Duties    │
│  │ Full text preview here...   │
│  │ [Read More]           📜     │
│  └───────────────────────────────┘  │
│                                     │
│  Quick Access                       │
│  ┌──────────────┬──────────────┐    │
│  │   📖         │   ❤️         │    │ ← QuickAccessGrid
│  │  Devotion    │ Counselling  │    │    (2-column grid)
│  │  Daily...    │  Notes...    │    │
│  ├──────────────┼──────────────┤    │
│  │   ✓          │   📅         │    │
│  │   Tasks      │  Schedule    │    │
│  │  Track...    │  Programs... │    │
│  ├──────────────┼──────────────┤    │
│  │   📝         │   🎵         │    │
│  │   Notes      │   Hymns      │    │
│  │  Sermon...   │  MHB...      │    │
│  └──────────────┴──────────────┘    │
│                                     │
│  ┌───────────────────────────────┐  │
│  │  View Pastoral Tasks      ✓   │  ← Purple CTA Button
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
        ↓ (Bottom Navigation Bar below)
```

## 🎨 Color Palette

### Primary Colors
| Name | Hex | Usage |
|------|-----|-------|
| Deep Indigo | #1F2A6B | Titles, primary text |
| Purple | #7C3AED | Hero header, accents |
| Gold/Amber | #FDB022 | CTAs, highlights |
| Light Lavender | #F7F5FB | Background |

### Quick Access Card Colors
| Card | Hex | Icon Color |
|------|-----|-----------|
| Devotion | #EDE9FE | #7C3AED |
| Counselling | #FECDD3 | #E91E63 |
| Tasks | #C8E6C9 | #4CAF50 |
| Schedule | #FFECB3 | #FBC02D |
| Notes | #B2DFDB | #009688 |
| Hymns | #C5CAE9 | #3F51B5 |

## 📏 Spacing Reference

```
Hero Header
├─ Top padding: 20pt
├─ Side padding: 20pt
├─ Internal gaps: 4-16pt
└─ Bottom: 24pt gap to next section

Standing Order Card
├─ Left/Right padding: 16pt
├─ Content area: 120-char preview
└─ Gap to next section: 28pt

Quick Access Grid
├─ Title: 24pt font, bold
├─ Gap to grid: 12pt
├─ Grid gaps: 12pt between cards
├─ Cards internal: 16pt padding
└─ Gap to button: 24pt

CTA Button
├─ Width: Full width (minus 16pt padding)
├─ Height: 56pt
├─ Corner radius: 28pt (pill shape)
└─ Shadow: Elevation 4
```

## 🎭 Typography System

### Heading 1 (Hero Greeting)
- **Font Size**: 28pt
- **Weight**: Bold
- **Color**: White
- **Line Height**: 1.2
- **Example**: "Welcome, Reverend"

### Heading 2 (Section Titles)
- **Font Size**: 24pt
- **Weight**: Bold
- **Color**: #1F2A6B
- **Example**: "Quick Access"

### Heading 3 (Card Titles)
- **Font Size**: 16pt
- **Weight**: Bold
- **Color**: #1F2A6B
- **Example**: "Devotion"

### Body Text
- **Font Size**: 14-15pt
- **Weight**: Regular
- **Color**: #666666
- **Line Height**: 1.4
- **Example**: "Daily scripture & reflections"

### Label Text
- **Font Size**: 12-13pt
- **Weight**: Medium (600)
- **Color**: #999999
- **Example**: "Today — Wednesday, December 10, 2025"

## ✨ Animation Effects

### Card Hover/Tap Animation
```
Before:        After (on hover/tap):
Scale: 1.0    Scale: 1.04
Shadow: 8px   Shadow: 12px
Duration: 200ms (smooth)

Effect: Card grows and lifts slightly,
        making it feel interactive
```

## 🔄 State Flow

```
HomeScreenModern (Init)
    ↓
initState() runs
    ↓
_fetchStandingOrderOfDay() called
    ↓
Queries Supabase standing_orders table
    ↓
Returns Map<String, dynamic> or null
    ↓
FutureBuilder rebuilds UI with data
    ↓
Display in StandingOrderOfTheDayCard

User taps Quick Access card:
    ↓
_isHovered state changes in QuickAccessCard
    ↓
AnimatedContainer rebuilds
    ↓
Card scales to 1.04x size
    ↓
showSnackBar displays tap feedback
```

## 📊 Responsive Behavior

### Mobile (< 600pt)
- 1-column grid for Quick Access cards
- Single column layout
- Full-width buttons
- Vertical stacking of all elements

### Tablet (≥ 600pt)
- 2-column grid for Quick Access (default)
- Cards remain vertically stacked
- Full-width buttons
- Same spacing throughout

*Note: Current implementation uses GridView.builder with fixed 2 columns.
For 1-column mobile support, can add MediaQuery check.*

## 🎯 Interactive Elements

### Clickable Areas
1. **Hero Header** - No interaction (static)
2. **Standing Order Card** - "Read More" button is clickable
3. **Quick Access Cards** - Entire card is tappable
4. **Purple Button** - Entire button is clickable

### Hover States
- Quick Access cards scale up 1.04x
- Shadow elevation increases
- Smooth 200ms transition

### Tap Feedback
- Currently shows SnackBar message
- Can be replaced with actual navigation

## 🎓 Key Features Highlighted

| Feature | Location | How It Works |
|---------|----------|-------------|
| Gradient Header | HeroHeader | LinearGradient with 2 purple shades |
| Dynamic Date | HeroHeader | DateFormat from intl package |
| Supabase Integration | HomeScreenModern | FutureBuilder + select() query |
| Responsive Grid | QuickAccessGrid | GridView.builder with 2 columns |
| Scale Animation | QuickAccessCard | AnimatedContainer with Matrix4.scale |
| Color Coding | QuickAccessCardData | 6 different pastel colors + icons |
| Truncation | StandingOrderOfTheDayCard | substring() with "..." suffix |
| Icons | All widgets | Material Design icons |

## 🔧 Quick Customization Tips

### Want a different color scheme?
- Edit color constants in each widget
- Recommended: Create a constants file and reference it

### Want different Quick Access cards?
- Modify `final cards = [...]` list in QuickAccessGrid
- Add or remove QuickAccessCardData entries

### Want to change spacing?
- Adjust `SizedBox(height: X)` values
- Modify `padding` properties on containers

### Want to add more sections?
- Add new Column children in HomeScreenModern.build()
- Create new helper widgets as needed
- Maintain consistent spacing and style

## 📱 Testing Checklist

- [ ] Can see gradient hero header with greeting
- [ ] Date displays correctly (today's date)
- [ ] Standing Order card shows content from database
- [ ] "Read More" button is clickable
- [ ] All 6 Quick Access cards visible
- [ ] Cards scale up on tap/hover
- [ ] Purple button at bottom is visible
- [ ] No text overflow on any element
- [ ] Works on different screen sizes
- [ ] Smooth animations (not janky)
- [ ] No console errors

---

**Design Inspiration**: Modern fintech dashboards with pastoral aesthetics
**Accessibility**: Sufficient color contrast, readable font sizes, tappable targets
**Performance**: Efficient StatefulWidget, lazy FutureBuilder, no unnecessary rebuilds
