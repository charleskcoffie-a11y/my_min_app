import 'package:flutter/material.dart';
import '../../models/song.dart';
import 'songs_repository.dart';
import '../../core/error_handler.dart';

class HymnalScreen extends StatefulWidget {
  const HymnalScreen({super.key});

  @override
  State<HymnalScreen> createState() => _HymnalScreenState();
}

class _HymnalScreenState extends State<HymnalScreen> {
  final _repo = SongsRepository();
  final _errorHandler = ErrorHandler();
  final _searchController = TextEditingController();

  // State variables
  String _activeTab = 'MHB'; // MHB, Canticles, CAN/Local, Favorites, All
  bool _loading = true;
  String? _errorMessage;
  List<Song> _allSongs = []; // All songs for current tab
  List<Song> _filteredSongs = []; // Filtered by search
  Song? _selectedSong;
  String _searchQuery = '';
  String _sortMode = 'number'; // 'number' or 'title'
  double _fontSize = 18;

  // Tab configuration
  static const Map<String, List<String>> tabCollections = {
    'MHB': ['MHB', 'General', 'HYMNS', 'SONGS'],
    'Canticles': ['CANTICLES_EN', 'CANTICLES_FANTE', 'CANTICLES', 'CANTICLE'],
    'CAN/Local': ['CAN', 'LOCAL', 'GHANA'],
    'Favorites': [],
    'All': [],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load songs for current tab
  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      List<Song> songs;

      if (_activeTab == 'Favorites') {
        songs = await _repo.getFavoriteSongs(sortBy: _sortMode);
      } else if (_activeTab == 'All') {
        songs = await _repo.getAllSongs(sortBy: _sortMode);
      } else {
        final collections = tabCollections[_activeTab] ?? [];
        songs = await _repo.getSongsByCollections(collections, sortBy: _sortMode);
      }

      if (!mounted) return;
      setState(() {
        _allSongs = songs;
        _errorMessage = null;
        _applySearch();
      });
    } catch (e, st) {
      if (!mounted) return;
      await _errorHandler.logError(e, st, context: 'HymnalScreen._load');
      setState(() => _errorMessage = _errorHandler.getErrorMessage(e));
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  /// Apply search filter to songs
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredSongs = _allSongs;
      return;
    }

    final query = _searchQuery.toLowerCase();
    _filteredSongs = _allSongs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.number.toString().contains(query) ||
          song.lyrics.toLowerCase().contains(query) ||
          song.code.toLowerCase().contains(query);
    }).toList();
  }

  /// Change active tab
  void _changeTab(String tab) {
    setState(() {
      _activeTab = tab;
      _searchQuery = '';
      _searchController.clear();
      _selectedSong = null;
    });
    _load();
  }

  /// Toggle favorite status
  Future<void> _toggleFavorite(Song song) async {
    final newStatus = !song.isFavorite;
    final oldStatus = song.isFavorite;

    // Optimistic update
    final index = _allSongs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      setState(() {
        _allSongs[index].isFavorite = newStatus;
        if (_selectedSong?.id == song.id) {
          _selectedSong = _allSongs[index];
        }
      });
    }

    // If in Favorites tab and unfavoriting, remove from visible list
    if (_activeTab == 'Favorites' && !newStatus) {
      _applySearch();
    }

    // Show toast
    _errorHandler.showSuccess(
      context,
      newStatus ? 'Added to Favorites' : 'Removed from Favorites',
      duration: const Duration(seconds: 2),
    );

    // Update Supabase
    try {
      await _repo.toggleFavorite(song.id, newStatus);
    } catch (e) {
      if (!mounted) return;
      // Restore old status on error
      if (index != -1) {
        setState(() {
          _allSongs[index].isFavorite = oldStatus;
          if (_selectedSong?.id == song.id) {
            _selectedSong = _allSongs[index];
          }
        });
      }
      _errorHandler.showError(context, 'Error updating favorite');
    }
  }

  /// Sort songs
  void _setSortMode(String mode) {
    setState(() => _sortMode = mode);
    _load();
  }

  /// Seed database with sample songs
  Future<void> _seedDatabase() async {
    try {
      await _repo.seedSampleSongs();
      if (!mounted) return;
      _errorHandler.showSuccess(context, 'Sample songs loaded!');
      _load();
    } catch (e) {
      if (!mounted) return;
      _errorHandler.showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show reading view if a song is selected
    if (_selectedSong != null) {
      return _buildReadingView();
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Tabs
          _buildTabs(),

          // Search and Sort
          _buildSearchAndSort(),

          // Main content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : _filteredSongs.isEmpty
                        ? _buildEmptyState()
                        : _buildSongGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Get color based on active tab
    final headerColor = _activeTab == 'MHB'
        ? Colors.blue.shade700
        : _activeTab == 'Canticles'
            ? Colors.purple.shade700
            : _activeTab == 'CAN/Local'
                ? Colors.teal.shade700
                : Colors.purple.shade700;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor, headerColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced from 20
      child: Row(
        children: [
          const Icon(Icons.music_note, color: Colors.white, size: 28), // Reduced from 32
          const SizedBox(width: 12), // Reduced from 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeTab == 'MHB' ? 'Hymns (MHB)' :
                  _activeTab == 'Canticles' ? 'Canticles' :
                  _activeTab == 'CAN/Local' ? 'CAN/Local Songs' :
                  'Canticles & Hymns',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20, // Reduced from 28
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Methodist Church Ghana • ${_allSongs.length} Songs',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12, // Reduced from 14
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _seedDatabase,
            icon: const Icon(Icons.cloud_download, size: 18),
            label: const Text('Load'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Favorites', 'MHB', 'Canticles', 'CAN/Local', 'All'];
    final icons = [
      Icons.star,
      Icons.book,
      Icons.play_circle_outline,
      Icons.public,
      Icons.list,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final icon = icons[index];
          final isActive = _activeTab == tab;

          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => _changeTab(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [Colors.purple.shade600, Colors.purple.shade400],
                        )
                      : null,
                  color: isActive ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: !isActive ? Border.all(color: Colors.grey.shade400) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isActive ? Colors.white : Colors.grey.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tab,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchAndSort() {
    final isCanticles = _activeTab == 'Canticles';
    final placeholder =
        isCanticles ? 'Search Canticles...' : 'Search by Number, Title, or Lyrics...';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _applySearch();
                  },
                  decoration: InputDecoration(
                    hintText: placeholder,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: _setSortMode,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'number',
                    child: Text('Sort: Number'),
                  ),
                  const PopupMenuItem(
                    value: 'title',
                    child: Text('Sort: Title'),
                  ),
                ],
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.sort,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongGrid() {
    // Sort by title if needed
    final displaySongs = _sortMode == 'title'
        ? (_filteredSongs.toList()..sort((a, b) => a.title.compareTo(b.title)))
        : _filteredSongs;

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: displaySongs.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 12, endIndent: 12),
      itemBuilder: (context, index) {
        final song = displaySongs[index];
        return _buildSongListItem(song);
      },
    );
  }

  /// Build a compact list item for a song
  /// Displays: Number | Title | Badge | Favorite button with minimal spacing
  Widget _buildSongListItem(Song song) {
    final collection = song.collection;
    final (bgColor, badgeLabel) = _getCollectionColor(collection);

    return GestureDetector(
      onTap: () => setState(() => _selectedSong = song),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Song number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                song.number.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: bgColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title - Expanded to take remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2558),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.code.isNotEmpty ? song.code : '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: bgColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Favorite button
            GestureDetector(
              onTap: () => _toggleFavorite(song),
              child: Icon(
                song.isFavorite ? Icons.star : Icons.star_outline,
                color: song.isFavorite ? Colors.amber : Colors.grey,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get color and badge label for collection
  (Color, String) _getCollectionColor(String collection) {
    if (collection.contains('MHB') || collection == 'General' || collection == 'HYMNS' || collection == 'SONGS') {
      return (Colors.blue.shade600, 'MHB');
    } else if (collection.contains('CANTICLES')) {
      return (Colors.purple.shade600, 'CANT');
    } else if (collection == 'CAN' || collection == 'LOCAL' || collection == 'GHANA') {
      return (Colors.teal.shade600, collection);
    }
    return (Colors.grey.shade600, collection);
  }

  /// Clean lyrics text
  String _cleanLyrics(String raw) {
    if (raw.isEmpty) return '';

    final lines = raw.split('\n');
    final cleaned = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();

      // Skip empty lines
      if (trimmed.isEmpty) {
        cleaned.add('');
        continue;
      }

      // Skip font artifacts
      if (trimmed.toLowerCase().startsWith('tahoma')) continue;

      // Skip punctuation-only lines
      if (RegExp(r'^[;:,.\-]+$').hasMatch(trimmed)) continue;

      // Skip verse/stanza labels
      if (RegExp(r'^(verse|stanza|hymn|chorus)\s*\d*\.?', caseSensitive: false).hasMatch(trimmed)) continue;

      // Skip lines that are just numbers
      if (RegExp(r'^\d+\.$').hasMatch(trimmed)) continue;

      // Remove leading -1, -2, etc.
      var processed = trimmed;
      if (RegExp(r'^-\d+\s').hasMatch(processed)) {
        processed = processed.replaceFirst(RegExp(r'^-\d+\s'), '');
      }

      cleaned.add(processed);
    }

    // Collapse multiple blank lines
    final result = <String>[];
    int blankCount = 0;
    for (final line in cleaned) {
      if (line.isEmpty) {
        blankCount++;
        if (blankCount <= 2) result.add(line);
      } else {
        blankCount = 0;
        result.add(line);
      }
    }

    return result.join('\n').trim();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error loading songs',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final message = _activeTab == 'Favorites'
        ? 'No favorites yet. Star songs to see them here.'
        : 'No songs found. Try searching for something else.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _activeTab == 'Favorites' ? Icons.star_outline : Icons.search,
              color: Colors.grey.shade400,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingView() {
    if (_selectedSong == null) return const SizedBox.shrink();

    final song = _selectedSong!;
    final cleanedLyrics = _cleanLyrics(song.lyrics);
    final (bgColor, _) = _getCollectionColor(song.collection);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with back button and controls
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => setState(() => _selectedSong = null),
            ),
            title: const Text('Reading View'),
            titleSpacing: 4, // Reduced spacing
            actions: [
              // Font size controls
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (_fontSize > 14) {
                    setState(() => _fontSize -= 2);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced from 8
                child: Center(
                  child: Text(
                    _fontSize.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 12), // Reduced from 14
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (_fontSize < 48) {
                    setState(() => _fontSize += 2);
                  }
                },
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  song.isFavorite ? Icons.star : Icons.star_outline,
                  color: song.isFavorite ? Colors.amber : null,
                ),
                onPressed: () => _toggleFavorite(song),
              ),
            ],
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgColor, bgColor.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        bgColor.withValues(alpha: 0.9),
                        bgColor.withValues(alpha: 0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16), // Reduced from 24
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Badge and number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: bgColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bgColor),
                        ),
                        child: Text(
                          '${song.collection} • ${song.code}',
                          style: TextStyle(
                            color: bgColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22, // Reduced from 28
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Georgia',
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced from 8

                  // Author
                  if (song.author != null && song.author!.isNotEmpty)
                    Text(
                      '— ${song.author}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Lyrics
                  SelectableText(
                    cleanedLyrics,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.3, // Reduced from 1.6 to tighten spacing
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 24), // Reduced from 32

                  // Footer
                  if (song.copyright != null && song.copyright!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Copyright',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            song.copyright!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  if (song.tags != null && song.tags!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: song.tags!
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
