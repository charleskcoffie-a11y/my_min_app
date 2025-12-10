import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Add to pubspec.yaml:
// file_picker: ^5.3.0
// csv: ^5.0.0
// share_plus: ^7.0.0

/// Program model class for church programs and events
class Program {
  final dynamic id; // Can be String or int from Supabase
  final String date; // YYYY-MM-DD format
  final String activityDescription;
  final String? venue;
  final String? lead;

  Program({
    required this.id,
    required this.date,
    required this.activityDescription,
    this.venue,
    this.lead,
  });

  /// Factory constructor from Supabase map
  factory Program.fromMap(Map<String, dynamic> map) {
    return Program(
      id: map['id'],
      date: map['date'] ?? '',
      activityDescription: map['activity_description'] ?? '',
      venue: map['venue'],
      lead: map['lead'],
    );
  }

  /// Convert to map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'activity_description': activityDescription,
      'venue': venue,
      'lead': lead,
    };
  }

  /// Create a copy with optional fields changed
  Program copyWith({
    dynamic id,
    String? date,
    String? activityDescription,
    String? venue,
    String? lead,
  }) {
    return Program(
      id: id ?? this.id,
      date: date ?? this.date,
      activityDescription: activityDescription ?? this.activityDescription,
      venue: venue ?? this.venue,
      lead: lead ?? this.lead,
    );
  }
}

/// Main Program Manager Screen
class ProgramManagerScreen extends StatefulWidget {
  const ProgramManagerScreen({super.key});

  @override
  State<ProgramManagerScreen> createState() => _ProgramManagerScreenState();
}

class _ProgramManagerScreenState extends State<ProgramManagerScreen> {
  // Supabase client
  late final SupabaseClient _supabase;

  // State variables
  List<Program> _programs = [];
  bool _loading = true;
  bool _importing = false;

  // Filter variables
  String _filterActivity = '';
  String _filterVenue = '';
  String _filterLead = '';
  String _filterStartDate = '';
  String _filterEndDate = '';

  // Editor state
  bool _isEditing = false;
  Program? _editingProgram;

  // Form controllers
  late TextEditingController _dateController;
  late TextEditingController _activityController;
  late TextEditingController _venueController;
  late TextEditingController _leadController;
  late TextEditingController _filterActivityController;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _dateController = TextEditingController();
    _activityController = TextEditingController();
    _venueController = TextEditingController();
    _leadController = TextEditingController();
    _filterActivityController = TextEditingController();
    _fetchPrograms();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _activityController.dispose();
    _venueController.dispose();
    _leadController.dispose();
    _filterActivityController.dispose();
    super.dispose();
  }

  /// Fetch all programs from Supabase
  Future<void> _fetchPrograms() async {
    try {
      setState(() => _loading = true);
      final response = await _supabase
          .from('church_programs')
          .select('*')
          .order('date', ascending: true);

      final programs =
          (response as List).map((p) => Program.fromMap(p)).toList();
      setState(() => _programs = programs);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading programs: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// Get unique venues from programs
  List<String> get _uniqueVenues {
    return _programs
        .where((p) => p.venue != null && p.venue!.isNotEmpty)
        .map((p) => p.venue!)
        .toSet()
        .toList()
        ..sort();
  }

  /// Get unique leads from programs
  List<String> get _uniqueLeads {
    return _programs
        .where((p) => p.lead != null && p.lead!.isNotEmpty)
        .map((p) => p.lead!)
        .toSet()
        .toList()
        ..sort();
  }

  /// Get filtered programs based on active filters
  List<Program> get _filteredPrograms {
    return _programs.where((p) {
      final matchActivity = p.activityDescription
          .toLowerCase()
          .contains(_filterActivity.toLowerCase());
      final matchVenue =
          _filterVenue.isEmpty || p.venue == _filterVenue;
      final matchLead = _filterLead.isEmpty || p.lead == _filterLead;
      final matchStart =
          _filterStartDate.isEmpty || p.date.compareTo(_filterStartDate) >= 0;
      final matchEnd =
          _filterEndDate.isEmpty || p.date.compareTo(_filterEndDate) <= 0;

      return matchActivity && matchVenue && matchLead && matchStart && matchEnd;
    }).toList();
  }

  /// Check if any filter is active
  bool get _isFilterActive {
    return _filterActivity.isNotEmpty ||
        _filterVenue.isNotEmpty ||
        _filterLead.isNotEmpty ||
        _filterStartDate.isNotEmpty ||
        _filterEndDate.isNotEmpty;
  }

  /// Clear all filters
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

  /// Save program (insert or update)
  Future<void> _saveProgram() async {
    final date = _dateController.text.trim();
    final activity = _activityController.text.trim();
    final venue = _venueController.text.trim();
    final lead = _leadController.text.trim();

    if (date.isEmpty || activity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date and Activity are required')),
      );
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
        // Update existing
        await _supabase
            .from('church_programs')
            .update(program.toMap())
            .eq('id', _editingProgram!.id);
      } else {
        // Insert new
        await _supabase.from('church_programs').insert(program.toMap());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _editingProgram != null ? 'Program updated' : 'Program added',
            ),
          ),
        );
        _closeEditor();
        _fetchPrograms();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving program: $e')),
        );
      }
    }
  }

  /// Delete program with confirmation
  Future<void> _deleteProgram(Program program) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program?'),
        content: const Text('This action cannot be undone.'),
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

    if (confirm != true) return;

    try {
      await _supabase.from('church_programs').delete().eq('id', program.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program deleted')),
        );
        _fetchPrograms();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting program: $e')),
        );
      }
    }
  }

  /// Open editor modal for new or existing program
  void _openEditor({Program? program}) {
    _editingProgram = program;
    if (program != null) {
      _dateController.text = program.date;
      _activityController.text = program.activityDescription;
      _venueController.text = program.venue ?? '';
      _leadController.text = program.lead ?? '';
    } else {
      _dateController.clear();
      _activityController.clear();
      _venueController.clear();
      _leadController.clear();
    }
    setState(() => _isEditing = true);
  }

  /// Close editor modal
  void _closeEditor() {
    setState(() => _isEditing = false);
    _editingProgram = null;
    _dateController.clear();
    _activityController.clear();
    _venueController.clear();
    _leadController.clear();
  }

  /// Flexible date parser (similar to React implementation)
  String? _parseFlexibleDate(String dateStr) {
    if (dateStr.trim().isEmpty) return null;

    final str = dateStr
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim()
        .toUpperCase();

    if (str == 'TBD' || str == 'DATE') return null;

    try {
      // Handle "Dec 1 to Dec 3, 2025" → take first part
      String workingStr = str;
      if (str.contains(' TO ')) {
        workingStr = str.split(' TO ')[0].trim();
        // If year is in second part but not first, append it
        if (!workingStr.contains(RegExp(r'\d{4}')) &&
            str.contains(RegExp(r'\d{4}'))) {
          final yearMatch = RegExp(r'(\d{4})').firstMatch(str);
          if (yearMatch != null) {
            workingStr = '$workingStr, ${yearMatch.group(1)}';
          }
        }
      }

      // Try parsing with various formats
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

  /// Get icon for activity type
  IconData _getActivityIcon(String description) {
    final lower = description.toLowerCase();

    if (lower.contains(RegExp(r'worship|choir|hymn|praise|song'))) {
      return Icons.music_note;
    } else if (lower.contains(RegExp(r'meeting|committee|board|council'))) {
      return Icons.briefcase;
    } else if (lower.contains(RegExp(r'prayer|vigil|fasting'))) {
      return Icons.favorite;
    } else if (lower.contains(RegExp(r'bible|study|class|training|seminar'))) {
      return Icons.school;
    } else if (lower.contains(RegExp(r'youth|fellowship|teen|children'))) {
      return Icons.people;
    } else if (lower.contains(RegExp(r'food|lunch|dinner|breakfast'))) {
      return Icons.local_dining;
    } else if (lower.contains(RegExp(r'preach|sermon'))) {
      return Icons.mic;
    } else {
      return Icons.calendar_today;
    }
  }

  /// CSV Import handler
  Future<void> _importCSV() async {
    // TODO: Use file_picker to select file
    // TODO: Use csv package to parse
    // Mock implementation for structure
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV import: Add file_picker and csv packages'),
      ),
    );
  }

  /// CSV Export handler
  Future<void> _exportCSV() async {
    try {
      // Build CSV content
      final buffer = StringBuffer();
      buffer.writeln('DATE,ACTIVITIES-DESCRIPTION,VENUE,LEAD');

      for (final program in _filteredPrograms) {
        final venue = program.venue ?? '';
        final lead = program.lead ?? '';
        buffer.writeln(
          '${program.date},"${program.activityDescription}",$venue,$lead',
        );
      }

      // TODO: Use share_plus to share the CSV
      // For now, just show a message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Export ready: ${_filteredPrograms.length} programs',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Filter card
            _buildFilterCard(),
            const SizedBox(height: 24),

            // Programs list / schedule
            _buildScheduleCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),

      // Editor modal
      floatingActionButton: _isEditing ? null : null,
      endDrawer: _isEditing ? _buildEditorDrawer() : null,
    );
  }

  /// Build header card with title and action buttons
  Widget _buildHeaderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section with title
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Program Schedule',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Church Programs · Events · Ministry Activities',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // Import CSV button
              ElevatedButton.icon(
                onPressed: _importCSV,
                icon: _importing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.green.shade600,
                          ),
                        ),
                      )
                    : const Icon(Icons.upload),
                label: const Text('Import CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // Export button
              OutlinedButton.icon(
                onPressed: _exportCSV,
                icon: const Icon(Icons.download),
                label: const Text('Export'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              // Add event button
              ElevatedButton.icon(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add),
                label: const Text('Add Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build filter card
  Widget _buildFilterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter title with clear button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Filter Programs',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                if (_isFilterActive)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter fields in responsive grid
            Column(
              children: [
                // Activity search
                TextField(
                  controller: _filterActivityController,
                  onChanged: (value) =>
                      setState(() => _filterActivity = value),
                  decoration: InputDecoration(
                    hintText: 'Search activity…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Date range row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() =>
                                _filterStartDate =
                                    date.toIso8601String().split('T')[0]);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'From date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _filterStartDate,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() =>
                                _filterEndDate =
                                    date.toIso8601String().split('T')[0]);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'To date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        controller: TextEditingController(
                          text: _filterEndDate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Venue and Lead dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterVenue.isEmpty ? null : _filterVenue,
                        hint: const Text('Select Venue'),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('All Venues'),
                          ),
                          ..._uniqueVenues.map((v) => DropdownMenuItem(
                            value: v,
                            child: Text(v),
                          )),
                        ],
                        onChanged: (value) =>
                            setState(() => _filterVenue = value ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterLead.isEmpty ? null : _filterLead,
                        hint: const Text('Select Lead'),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('All Leads'),
                          ),
                          ..._uniqueLeads.map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(l),
                          )),
                        ],
                        onChanged: (value) =>
                            setState(() => _filterLead = value ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build schedule/programs list card
  Widget _buildScheduleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Loading schedule…'),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            : _filteredPrograms.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Header row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            const SizedBox(width: 80, child: Text('Date')),
                            Expanded(
                              child: Text(
                                'Activity',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            const SizedBox(width: 120, child: Text('Venue')),
                            const SizedBox(width: 80),
                          ],
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Program rows
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _filteredPrograms.length,
                        itemBuilder: (context, index) {
                          final program = _filteredPrograms[index];
                          return _buildProgramRow(program);
                        },
                      ),
                    ],
                  ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 40,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No programs found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual program row
  Widget _buildProgramRow(Program program) {
    final dateObj = DateTime.parse(program.date);
    final dayName = DateFormat('EEE').format(dateObj);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          // Date block
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Text(
                  program.date.split('-')[2], // Day
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A6B),
                  ),
                ),
                Text(
                  dayName,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Activity with icon
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getActivityIcon(program.activityDescription),
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        program.activityDescription,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (program.lead != null && program.lead!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Lead: ${program.lead}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Venue
          SizedBox(
            width: 120,
            child: program.venue != null && program.venue!.isNotEmpty
                ? Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          program.venue!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '—',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
          ),

          // Edit/Delete buttons
          SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _openEditor(program: program),
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _deleteProgram(program),
                  icon: const Icon(Icons.delete, size: 18),
                  color: Colors.red.shade600,
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build editor drawer/modal
  Widget _buildEditorDrawer() {
    return Drawer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _editingProgram != null
                      ? 'Edit Ministry Event'
                      : 'New Ministry Event',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: _closeEditor,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Date field
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.tryParse(_dateController.text) ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  _dateController.text =
                      date.toIso8601String().split('T')[0];
                }
              },
              decoration: InputDecoration(
                labelText: 'Date *',
                hintText: 'YYYY-MM-DD',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Activity field
            TextField(
              controller: _activityController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Activity Description *',
                hintText: 'Describe the ministry activity…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Venue field
            TextField(
              controller: _venueController,
              decoration: InputDecoration(
                labelText: 'Venue',
                hintText: 'Location of the event',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lead field
            TextField(
              controller: _leadController,
              decoration: InputDecoration(
                labelText: 'Lead',
                hintText: 'Person leading the activity',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _closeEditor,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProgram,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
