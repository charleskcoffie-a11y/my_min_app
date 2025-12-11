import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/counseling_session.dart';
import '../../repositories/counseling_session_repository.dart';

/// Master code for counseling journal access
const String COUNSELING_MASTER_CODE = '1234'; // Change this to your desired code

const List<String> CASE_TYPES = [
  'Marriage',
  'Family',
  'Addiction',
  'Youth',
  'Bereavement',
  'Spiritual',
  'Other',
];

const List<String> STATUSES = ['Open', 'In Progress', 'Closed'];

/// Secure Counseling Journal with master code protection
class CounselingJournalScreen extends StatefulWidget {
  const CounselingJournalScreen({super.key});

  @override
  State<CounselingJournalScreen> createState() =>
      _CounselingJournalScreenState();
}

class _CounselingJournalScreenState extends State<CounselingJournalScreen> {
  final _repository = CounselingSessionRepository();

  // Security State
  bool _isLocked = true;
  bool _blurMode = true;
  String _inputCode = '';
  String _lockError = '';

  // Data State
  List<CounselingSession> _sessions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterStatus = 'All';

  // Modal State
  bool _isModalOpen = false;
  late CounselingSession _editingSession;
  bool _createReminder = false;

  @override
  void initState() {
    super.initState();
    _resetForm();
  }

  /// Reset form to empty state
  void _resetForm() {
    _editingSession = CounselingSession(
      id: '',
      initials: '',
      caseType: 'Spiritual',
      status: 'Open',
      summary: '',
      createdAt: DateTime.now(),
    );
  }

  /// Handle unlock with master code
  void _handleUnlock() {
    if (_inputCode == COUNSELING_MASTER_CODE) {
      setState(() {
        _isLocked = false;
        _lockError = '';
        _inputCode = '';
      });
      _loadSessions();
    } else {
      setState(() {
        _lockError = 'Incorrect Master Code';
        _inputCode = '';
      });
    }
  }

  /// Load all counseling sessions
  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _repository.getAllSessions();
      setState(() => _sessions = sessions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sessions: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Save counseling session
  Future<void> _saveSession() async {
    if (_editingSession.initials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter initials')),
      );
      return;
    }

    try {
      if (_editingSession.id == null) {
        await _repository.insertSession(_editingSession);
      } else {
        await _repository.updateSession(_editingSession);
      }

      await _loadSessions();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingSession.id == null
                ? 'Case created'
                : 'Case updated'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  /// Delete counseling session
  Future<void> _deleteSession(CounselingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Case?'),
        content: Text(
            'Delete case for ${session.initials}? This cannot be undone.'),
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
        await _repository.deleteSession(session.id!);
        await _loadSessions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  /// Get icon for case type
  IconData _getCaseTypeIcon(String type) {
    switch (type) {
      case 'Marriage':
        return Icons.favorite;
      case 'Family':
        return Icons.people;
      case 'Youth':
        return Icons.child_care;
      case 'Addiction':
        return Icons.warning;
      case 'Bereavement':
        return Icons.sentiment_dissatisfied;
      case 'Spiritual':
        return Icons.auto_awesome;
      default:
        return Icons.psychology;
    }
  }

  /// Get color for case type
  Color _getCaseTypeColor(String type) {
    switch (type) {
      case 'Marriage':
        return Colors.red;
      case 'Family':
        return Colors.blue;
      case 'Youth':
        return Colors.green;
      case 'Addiction':
        return Colors.amber;
      case 'Bereavement':
        return Colors.purple;
      case 'Spiritual':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Filter sessions
  List<CounselingSession> _getFilteredSessions() {
    return _sessions.where((s) {
      final matchSearch = s.initials.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (s.summary?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchStatus =
          _filterStatus == 'All' ? true : s.status == _filterStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Locked view
    if (_isLocked) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F7FD),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lock icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Confidential Notes',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2558),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'This area is protected to ensure the privacy\nof pastoral counseling records.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Code input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            obscureText: true,
                            onChanged: (value) =>
                                setState(() => _inputCode = value),
                            onSubmitted: (_) => _handleUnlock(),
                            decoration: InputDecoration(
                              hintText: 'Enter Master Code',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.vpn_key),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                          if (_lockError.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _lockError,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleUnlock,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A1B9A),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                              child: Text(
                                'Access Records',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Unlocked view
    final filteredSessions = _getFilteredSessions();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          'Counseling Journal',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_blurMode ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _blurMode = !_blurMode),
            tooltip: _blurMode ? 'Privacy Mode On' : 'Privacy Mode Off',
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () => setState(() => _isLocked = true),
            tooltip: 'Lock',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security badge
                    if (_blurMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          border: Border.all(color: Colors.indigo.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.privacy_tip, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Privacy Mode: ON',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Search and filter
                    TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search by initials or notes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          ...STATUSES,
                        ]
                            .map(
                              (status) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(status),
                                  selected: _filterStatus == status,
                                  onSelected: (selected) {
                                    setState(() => _filterStatus = status);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _resetForm();
                          setState(() => _isModalOpen = true);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New Case'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sessions list
                    if (filteredSessions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No counseling records found',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = filteredSessions[index];
                          return _buildSessionCard(session);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Build session card
  Widget _buildSessionCard(CounselingSession session) {
    final isOverdue = session.followUpDate != null &&
        session.followUpDate!.isBefore(DateTime.now()) &&
        session.status != 'Closed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _editingSession = session;
            _isModalOpen = true;
          });
        },
        onLongPress: () => _deleteSession(session),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCaseTypeColor(session.caseType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCaseTypeIcon(session.caseType),
                      color: _getCaseTypeColor(session.caseType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _blurMode ? '***' : session.initials,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          session.caseType,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(session.status)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      session.status,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(session.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Summary
              if (session.summary != null && session.summary!.isNotEmpty)
                Text(
                  _blurMode ? '•••••••••••' : session.summary!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.createdAt != null
                        ? DateFormat('MMM d, y').format(session.createdAt!)
                        : 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (session.followUpDate != null)
                    Text(
                      DateFormat('MMM d').format(session.followUpDate!),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isOverdue
                            ? Colors.red.shade600
                            : Colors.blue.shade600,
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

  /// Build edit/create modal
  void _showModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20) +
                EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _editingSession.id == null ? 'New Case' : 'Edit Case',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Initials
                TextField(
                  onChanged: (value) {
                    _editingSession = _editingSession.copyWith(
                      initials: value.toUpperCase(),
                    );
                  },
                  decoration: InputDecoration(
                    labelText: 'Initials (Required)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  controller: TextEditingController(
                    text: _editingSession.initials,
                  ),
                ),
                const SizedBox(height: 12),

                // Case type
                DropdownButtonFormField<String>(
                  value: _editingSession.caseType,
                  items: CASE_TYPES
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    _editingSession =
                        _editingSession.copyWith(caseType: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Case Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: 12),

                // Status
                DropdownButtonFormField<String>(
                  value: _editingSession.status,
                  items: STATUSES
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    _editingSession = _editingSession.copyWith(status: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.info),
                  ),
                ),
                const SizedBox(height: 12),

                // Summary
                TextField(
                  onChanged: (value) {
                    _editingSession =
                        _editingSession.copyWith(summary: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Summary',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(
                    text: _editingSession.summary ?? '',
                  ),
                ),
                const SizedBox(height: 12),

                // Key Issues
                TextField(
                  onChanged: (value) {
                    _editingSession =
                        _editingSession.copyWith(keyIssues: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Key Issues',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(
                    text: _editingSession.keyIssues ?? '',
                  ),
                ),
                const SizedBox(height: 12),

                // Scriptures
                TextField(
                  onChanged: (value) {
                    _editingSession =
                        _editingSession.copyWith(scripturesUsed: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Scriptures Used',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                  controller: TextEditingController(
                    text: _editingSession.scripturesUsed ?? '',
                  ),
                ),
                const SizedBox(height: 12),

                // Action steps
                TextField(
                  onChanged: (value) {
                    _editingSession =
                        _editingSession.copyWith(actionSteps: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Action Steps',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(
                    text: _editingSession.actionSteps ?? '',
                  ),
                ),
                const SizedBox(height: 12),

                // Prayer points
                TextField(
                  onChanged: (value) {
                    _editingSession =
                        _editingSession.copyWith(prayerPoints: value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Prayer Points',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  controller: TextEditingController(
                    text: _editingSession.prayerPoints ?? '',
                  ),
                ),
                const SizedBox(height: 20),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveSession();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Save Record',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
