# Supabase Songs Table Setup Guide

## Quick Setup

### Step 1: Create the Songs Table

Go to your Supabase project and run this SQL in the SQL Editor:

```sql
-- Create songs table
CREATE TABLE IF NOT EXISTS songs (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  collection TEXT NOT NULL,
  code TEXT NOT NULL,
  number INT NOT NULL,
  title TEXT NOT NULL,
  lyrics TEXT NOT NULL,
  author TEXT,
  copyright TEXT,
  tags TEXT[],
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_songs_collection ON songs(collection);
CREATE INDEX idx_songs_number ON songs(number);
CREATE INDEX idx_songs_is_favorite ON songs(is_favorite);

-- Enable RLS (optional but recommended)
ALTER TABLE songs ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
CREATE POLICY "Public read access" ON songs
  FOR SELECT USING (true);

-- Create policy for authenticated users to update favorites
CREATE POLICY "Users can update their favorites" ON songs
  FOR UPDATE USING (true)
  WITH CHECK (true);
```

### Step 2: Insert Sample Data (Optional)

The app has a "Load Sample" button that will auto-populate 3 songs, or run this SQL:

```sql
-- Insert sample songs
INSERT INTO songs (collection, code, number, title, lyrics, author, copyright, tags) VALUES
(
  'MHB',
  'MHB-1',
  1,
  'God the Omnipotent',
  'God the Omnipotent!
King, whom earth and sea and sky
Adore and own allegiance,
Ancient of days, Whom we in faith appeal to,
Hear us when we cry to Thee.

God the All-merciful,
By the fire of Thy chastisings,
Ere to its bitter close
Be brought the reign of cruelty,
Pity our affliction,
Hear us when we cry to Thee.',
  'Walter Shirley',
  'Public Domain',
  ARRAY['hymn', 'praise', 'god']
),
(
  'CANTICLES_EN',
  'CANT-1',
  1,
  'Magnificat',
  'My soul doth magnify the Lord,
And my spirit hath rejoiced in God my Saviour.
For he hath regarded the lowliness of his handmaiden:
for behold, from henceforth all generations shall call me blessed.

For he that is mighty hath magnified me;
and holy is his Name.
And his mercy is on them that fear him throughout all generations.
He hath shewed strength with his arm;
he hath scattered the proud in the imagination of their hearts.',
  'St. Luke 1:46-51',
  'Public Domain',
  ARRAY['canticle', 'mary', 'worship']
),
(
  'MHB',
  'MHB-72',
  72,
  'Lead, Kindly Light',
  'Lead, kindly Light, amid the encircling gloom,
Lead Thou me on!
The night is dark, and I am far from home—
Lead Thou me on!
Keep Thou my feet; I do not ask to see
The distant scene—one step enough for me.

I was not ever thus, nor prayed that Thou
Shouldst lead me on.
I loved to choose and see my path; but now
Lead Thou me on!
I loved the garish day, and, spite of fears,
Pride ruled my will: remember not past years.',
  'John Henry Newman',
  'Public Domain',
  ARRAY['hymn', 'faith', 'guidance']
);
```

### Step 3: Verify Table Creation

In Supabase, go to **Table Editor** and confirm:
- ✅ Table name: `songs`
- ✅ Columns: id, collection, code, number, title, lyrics, author, copyright, tags, is_favorite
- ✅ Sample data visible (if inserted)

## Collection Values Reference

Use these collection strings when adding songs:

**Methodist Hymn Book Collections**:
- `MHB` - Methodist Hymn Book
- `General` - General hymns
- `HYMNS` - Hymn collection
- `SONGS` - Song collection

**Canticles Collections**:
- `CANTICLES_EN` - English canticles
- `CANTICLES_FANTE` - Fante canticles
- `CANTICLES` - Generic canticles
- `CANTICLE` - Single canticle

**Ghanaian/Local Collections**:
- `CAN` - Canticles (local variant)
- `LOCAL` - Local hymns
- `GHANA` - Ghana-specific hymns

## Testing the Integration

1. **Verify Connection**:
   - Open app and navigate to Hymns tab
   - You should see loading spinner
   - If connected, songs will load

2. **Test Sample Data Loading**:
   - Tap "Load Sample" button in header
   - Wait for loading to complete
   - Should see 3 songs in grid

3. **Test Search**:
   - Type "God" in search field
   - Should filter to "God the Omnipotent"

4. **Test Favorites**:
   - Click star on a song card
   - Switch to Favorites tab
   - Song should appear

5. **Test Reading View**:
   - Click on any song card
   - Should show full reading view with:
     - Title and author
     - Full lyrics
     - Font size controls
     - Favorite button
     - Copyright info

## Troubleshooting

**Songs not loading?**
- Check Supabase URL and key in `lib/secrets.dart`
- Verify table exists in Supabase console
- Check Supabase RLS policies aren't blocking reads
- Check network connectivity

**Sample data button not working?**
- Ensure `is_favorite` column allows inserts
- Check Supabase write permissions
- Verify collection names match exactly

**Search not working?**
- Lyrics must be plain text (no special formatting)
- Search is case-insensitive and partial match
- Clear search field and try simple words

**App crashes on hymnal tab?**
- Check error handler service exists
- Verify imports in hymnal_screen.dart
- Run `flutter analyze` to check compilation

## Data Format Notes

- **Lyrics**: Plain text with \n for line breaks. Cleaning handles special characters.
- **Tags**: Array of strings. Optional but recommended for filtering.
- **Author**: Can be blank ("") if unknown
- **Copyright**: Can be blank for public domain
- **Is_favorite**: Boolean (true/false). Defaults to false.

## Next Steps

Once table is created and verified:
1. Build and run the app: `flutter run -d <deviceId>`
2. Navigate to Hymns tab
3. Tap "Load Sample" to populate initial data
4. Search, sort, and manage your hymnal!

---

For more information, see `HYMNAL_IMPLEMENTATION.md`
