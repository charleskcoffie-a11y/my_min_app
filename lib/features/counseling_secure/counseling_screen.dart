import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../models/counseling_session.dart';
import '../../repositories/counseling_repository.dart';
import 'counseling_form_screen.dart';

/// Secure Counseling Journal Screen
/// 
/// Features:
/// - Master code protection
/// - Privacy/blur mode
/// - Full CRUD operations
/// - Search and filter
/// - Reminder creation
class CounselingScreen extends StatefulWidget {
  const CounselingScreen({super.key});

  @override
  State<CounselingScreen> createState() => _CounselingScreenState();
}

class _CounselingScreenState extends State<CounselingScreen> {
  final _repository = CounselingRepository();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLocked = true;
  bool _blurMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'All';
  String _searchQuery = '';

  List<CounselingSession> _allSessions = [];
  List<CounselingSession> _filteredSessions = [];

  @override
  void dispose() {
    _passwordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Unlock the screen if password is correct
  Future<void> _unlock() async {
    if (_passwordController.text == CounselingConstants.masterCode) {
      setState(() {
        _isLocked = false;
        _errorMessage = null;
      });
      await _loadSessions();
    } else {
      setState(() => _errorMessage = 'Incorrect Master Code');
    }
  }

  /// Lock the screen and clear data
  void _lock() {
    setState(() {
      _isLocked = true;
      _allSessions = [];
      _filteredSessions = [];
      _passwordController.clear();
      _searchQuery = '';
      _searchController.clear();
      _selectedStatus = 'All';
      _blurMode = false;
    });
  }

  /// Load sessions from Supabase
  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final sessions = await _repository.getAllSessions();
      setState(() {
        _allSessions = sessions;
        _applyFilters();
      });
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

  /// Apply search and status filters
  void _applyFilters() {
    var filtered = _allSessions;

    // Status filter
    if (_selectedStatus != 'All') {
      filtered = filtered.where((s) => s.status == _selectedStatus).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.initials.toLowerCase().contains(query) ||
            s.summary.toLowerCase().contains(query);
      }).toList();
    }

    setState(() => _filteredSessions = filtered);
  }

  /// Delete a session with confirmation
  Future<void> _deleteSession(CounselingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Counseling Record?'),
        content: Text(
          'This will permanently delete the counseling record for "${session.initials}". This action cannot be undone.',
        ),
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
        await _repository.deleteSession(session.id);
        await _loadSessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Counseling record deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting session: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      body: _isLocked ? _buildLockedView() : _buildSecureView(),
    );
  }

  /// Locked view with password input
  Widget _buildLockedView() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lock icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A1B9A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 40,
                      color: Color(0xFF6A1B9A),
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
                  // Subtitle
                  Text(
                    'This area is protected to ensure privacy and confidentiality of sensitive pastoral care records.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Password field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Enter Master Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key),
                    ),
                    onSubmitted: (_) => _unlock(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Access button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _unlock,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Access Records',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  /// Secure view with sessions list
  Widget _buildSecureView() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchAndFilter(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _filteredSessions.isEmpty
                    ? _buildEmptyState()
                    : _buildSessionsList(),
          ),
        ],
      ),
    );
  }

  /// Header with title and action buttons
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981),
            const Color(0xFF10B981).withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Counseling Journal',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A safe space for documenting pastoral care',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              IconButton(
                onPressed: () {
                  setState(() => _blurMode = !_blurMode);
                },
                icon: Icon(
                  _blurMode ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                tooltip: _blurMode ? 'Show Content' : 'Hide Content',
              ),
              IconButton(
                onPressed: () => _openForm(null),
                icon: const Icon(Icons.add, color: Colors.white),
                tooltip: 'New Case',
              ),
              IconButton(
                onPressed: _lock,
                icon: const Icon(Icons.lock_outline, color: Colors.white),
                tooltip: 'Lock',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Status chips
          Row(
            children: [
              _buildChip('Secure Area', Icons.shield, Colors.white),
              if (_blurMode) ...[
                const SizedBox(width: 8),
                _buildChip('Privacy Mode On', Icons.blur_on, Colors.amber),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Search and status filter bar
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by initials or summary...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusChip('All'),
                ...CounselingConstants.statuses.map((status) => _buildStatusChip(status)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedStatus = status);
          _applyFilters();
        },
        selectedColor: const Color(0xFF6A1B9A).withOpacity(0.2),
        checkmarkColor: const Color(0xFF6A1B9A),
      ),
    );
  }

  /// Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Retrieving secure records...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Pastoral Care',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2558),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No counseling records found matching your criteria. When you begin a case, it will appear here as a secure journal.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openForm(null),
              icon: const Icon(Icons.add),
              label: const Text('Start a New Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sessions list
  Widget _buildSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(_filteredSessions[index]);
      },
    );
  }

  /// Session card
  Widget _buildSessionCard(CounselingSession session) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteSession(session);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _openForm(session),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with initials
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _buildBlurrableText(
                          session.initials,
                          TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(session.status),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Initials and case type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBlurrableText(
                            session.initials,
                            GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2558),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                _getCaseIcon(session.caseType),
                                size: 14,
                                color: const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session.caseType,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
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
                // Summary preview
                _buildBlurrableText(
                  session.summary,
                  GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                // Footer with dates
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, y').format(session.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    if (session.followUpDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: session.isFollowUpOverdue
                              ? Colors.red.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event,
                              size: 12,
                              color: session.isFollowUpOverdue ? Colors.red : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Follow-up: ${DateFormat('MMM d').format(session.followUpDate!)}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: session.isFollowUpOverdue ? Colors.red : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'No follow-up',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build text with optional blur effect
  Widget _buildBlurrableText(
    String text,
    TextStyle style, {
    int? maxLines,
  }) {
    if (_blurMode) {
      return ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Text(
          text,
          style: style,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
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

  /// Get case type icon
  IconData _getCaseIcon(String caseType) {
    switch (caseType) {
      case 'Marriage':
        return Icons.favorite;
      case 'Family':
        return Icons.family_restroom;
      case 'Addiction':
        return Icons.healing;
      case 'Youth':
        return Icons.group;
      case 'Bereavement':
        return Icons.park;
      case 'Spiritual':
        return Icons.auto_awesome;
      default:
        return Icons.help_outline;
    }
  }

  /// Open form for creating/editing session
  Future<void> _openForm(CounselingSession? session) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CounselingFormScreen(session: session),
      ),
    );

    if (result == true) {
      await _loadSessions();
    }
  }
}
