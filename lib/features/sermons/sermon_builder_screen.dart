import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/sermon.dart';
import '../../repositories/sermon_repository.dart';
import 'sermon_editor_screen.dart';

/// Sermon Builder - List view showing all sermons
class SermonBuilderScreen extends StatefulWidget {
  const SermonBuilderScreen({super.key});

  @override
  State<SermonBuilderScreen> createState() => _SermonBuilderScreenState();
}

class _SermonBuilderScreenState extends State<SermonBuilderScreen> {
  final _repository = SermonRepository();
  
  List<Sermon> _sermons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSermons();
  }

  /// Load all sermons
  Future<void> _loadSermons() async {
    setState(() => _isLoading = true);
    try {
      final sermons = await _repository.getAllSermons();
      setState(() => _sermons = sermons);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sermons: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Delete sermon with confirmation
  Future<void> _deleteSermon(Sermon sermon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sermon?'),
        content: Text('Delete "${sermon.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteSermon(sermon.id);
        await _loadSermons();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting sermon: $e')),
          );
        }
      }
    }
  }

  /// Navigate to editor
  Future<void> _editSermon(Sermon? sermon) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SermonEditorScreen(sermon: sermon),
      ),
    );

    if (result == true) {
      await _loadSermons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    'Sermon Builder',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2558),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: () => _editSermon(null),
                        icon: const Icon(Icons.add),
                        label: const Text('New Sermon'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Content
                if (_sermons.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No sermons yet',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2558),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first sermon to get started',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => _editSermon(null),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Create First Sermon',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 180,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sermon = _sermons[index];
                          return _buildSermonCard(sermon);
                        },
                        childCount: _sermons.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  /// Build sermon card
  Widget _buildSermonCard(Sermon sermon) {
    final progress = _calculateProgress(sermon);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _editSermon(sermon),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sermon.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2558),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () => _editSermon(sermon),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onTap: () => _deleteSermon(sermon),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Scripture and theme
              if (sermon.mainText.isNotEmpty)
                Text(
                  sermon.mainText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              if (sermon.theme.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Theme: ${sermon.theme}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const Spacer(),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress}% Complete',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        progress >= 100 ? 'Ready' : 'Drafting',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: progress >= 100 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 100 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Calculate completion percentage
  int _calculateProgress(Sermon sermon) {
    int filled = 0;
    int total = 12;

    if (sermon.title.isNotEmpty) filled++;
    if (sermon.mainText.isNotEmpty) filled++;
    if (sermon.introduction.isNotEmpty) filled++;
    if (sermon.backgroundContext.isNotEmpty) filled++;
    if (sermon.mainPoints.isNotEmpty) filled++;
    if (sermon.applications.isNotEmpty) filled++;
    if (sermon.gospelConnection.isNotEmpty) filled++;
    if (sermon.conclusion.isNotEmpty) filled++;
    if (sermon.prayerPoints.isNotEmpty) filled++;
    if (sermon.altarCall.isNotEmpty) filled++;
    if (sermon.theme.isNotEmpty) filled++;
    if (sermon.proposition.isNotEmpty) filled++;

    return ((filled / total) * 100).round();
  }
}
