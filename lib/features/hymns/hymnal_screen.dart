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
        ? Colors.blue
        : _activeTab == 'Canticles'
            ? Colors.purple
            : _activeTab == 'CAN/Local'
                ? Colors.teal
                : Colors.purple;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor.shade400, headerColor.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_allSongs.length} songs',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Methodist Church Ghana',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Favorites', 'MHB', 'Canticles', 'CAN/Local', 'All'];
    final icons = [
      Icons.star_rounded,
      Icons.book_rounded,
      Icons.play_circle_outline_rounded,
      Icons.public_rounded,
      Icons.list_rounded,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final icon = icons[index];
          final isActive = _activeTab == tab;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: GestureDetector(
                onTap: () => _changeTab(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [Colors.purple.shade400, Colors.purple.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isActive ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isActive
                        ? [BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        color: isActive ? Colors.white : Colors.grey.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey.shade700,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  _applySearch();
                },
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _applySearch();
                          },
                          child: Icon(Icons.close_rounded, color: Colors.grey.shade600, size: 20),
                        )
                      : null,
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [Colors.grey.shade100, Colors.grey.shade50],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              onSelected: _setSortMode,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'number',
                  child: Row(
                    children: [
                      Icon(Icons.format_list_numbered, color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      const Text('Sort by Number'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'title',
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      const Text('Sort by Title'),
                    ],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.tune_rounded,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
              ),
            ),
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
      padding: const EdgeInsets.all(12),
      itemCount: displaySongs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final song = displaySongs[index];
        return _buildSongCard(song);
      },
    );
  }

  /// Build a modern card-based song item with better visual hierarchy
  Widget _buildSongCard(Song song) {
    final collection = song.collection;
    final (bgColor, badgeLabel) = _getCollectionColor(collection);

    return GestureDetector(
      onTap: () => setState(() => _selectedSong = song),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _selectedSong = song),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Song number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [bgColor.withValues(alpha: 0.7), bgColor],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      song.number.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2558),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (song.code.isNotEmpty)
                          Text(
                            song.code,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Collection badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: bgColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
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
                      song.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: song.isFavorite ? Colors.amber.shade400 : Colors.grey.shade400,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something went wrong',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Error loading songs',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _activeTab == 'Favorites' ? Icons.star_outline_rounded : Icons.search_rounded,
                color: Colors.grey.shade500,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _activeTab == 'Favorites' ? 'No Favorites Yet' : 'Nothing Found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
          // Modern app bar with blur effect
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => setState(() => _selectedSong = null),
            ),
            title: const Text('Now Reading'),
            titleSpacing: 0,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade900,
            actions: [
              // Font size controls in a compact row
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      onPressed: () {
                        if (_fontSize > 14) {
                          setState(() => _fontSize -= 2);
                        }
                      },
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: const EdgeInsets.all(6),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _fontSize.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () {
                        if (_fontSize < 48) {
                          setState(() => _fontSize += 2);
                        }
                      },
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  song.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: song.isFavorite ? Colors.amber.shade400 : Colors.grey.shade600,
                ),
                onPressed: () => _toggleFavorite(song),
              ),
              const SizedBox(width: 8),
            ],
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bgColor.withValues(alpha: 0.7), bgColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title with better typography
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2558),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Author with modern styling
                  if (song.author != null && song.author!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        '— ${song.author}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  // Metadata badges
                  Wrap(
                    spacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bgColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          song.collection,
                          style: TextStyle(
                            color: bgColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (song.code.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            song.code,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Lyrics with optimized readability
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SelectableText(
                      cleanedLyrics,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.8,
                        color: Colors.grey.shade900,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Copyright and tags
                  if (song.copyright != null && song.copyright!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Copyright',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            song.copyright!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (song.tags != null && song.tags!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: song.tags!
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.purple.shade100, Colors.purple.shade200],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.purple.shade300),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
