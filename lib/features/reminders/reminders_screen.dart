import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/reminder.dart';
import '../../core/gemini_service.dart';

const List<String> CATEGORIES = [
  'Sermon Preparation',
  'Visitation',
  'Counseling',
  'Prayer & Fasting',
  'Meeting',
  'Personal Devotion',
  'Other',
];

const List<String> FREQUENCIES = [
  'One-time',
  'Daily',
  'Weekly',
  'Monthly',
  'Yearly',
];

/// Pastoral Reminders System
class RemindersScreen extends StatefulWidget {
  final GeminiService? gemini;

  const RemindersScreen({super.key, this.gemini});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _supabase = Supabase.instance.client;

  List<Reminder> _reminders = [];
  bool _isLoading = true;
  String _filter = 'active'; // 'active' or 'inactive'

  // Modal state
  bool _isModalOpen = false;
  late Reminder _editingReminder;

  // AI state
  bool _isAiModalOpen = false;
  List<Map<String, dynamic>> _aiSuggestions = [];
  bool _aiLoading = false;

  @override
  void initState() {
    super.initState();
    _resetForm();
    _fetchReminders();
  }

  /// Reset form
  void _resetForm() {
    _editingReminder = Reminder(
      title: '',
      category: 'Personal Devotion',
      frequency: 'One-time',
      startDate: DateTime.now(),
      notes: '',
      isActive: true,
    );
  }

  /// Fetch reminders
  Future<void> _fetchReminders() async {
    setState(() => _isLoading = true);
    try {
      final response = await _supabase
          .from('reminders')
          .select()
          .order('start_date', ascending: true);

      setState(() {
        _reminders = (response as List)
            .map((json) => Reminder.fromMap(json as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Save reminder
  Future<void> _saveReminder() async {
    if (_editingReminder.title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    try {
      if (_editingReminder.id == null) {
        // Create
        await _supabase.from('reminders').insert(_editingReminder.toMap());
      } else {
        // Update
        await _supabase
            .from('reminders')
            .update(_editingReminder.toMap())
            .eq('id', _editingReminder.id!);
      }

      await _fetchReminders();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    }
  }

  /// Delete reminder
  Future<void> _deleteReminder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder?'),
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

    if (confirmed == true) {
      try {
        await _supabase.from('reminders').delete().eq('id', id);
        await _fetchReminders();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      }
    }
  }

  /// Toggle active status
  Future<void> _toggleStatus(Reminder reminder) async {
    try {
      await _supabase
          .from('reminders')
          .update({'is_active': !reminder.isActive})
          .eq('id', reminder.id!);
      await _fetchReminders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating: $e')),
      );
    }
  }

  /// AI suggestions
  Future<void> _generateAiSuggestions() async {
    if (widget.gemini == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI service not available')),
      );
      return;
    }

    setState(() {
      _isAiModalOpen = true;
      _aiLoading = true;
      _aiSuggestions = [];
    });

    try {
      // Fetch context
      final tasks = await _supabase.from('tasks').select().limit(10);
      final programs = await _supabase.from('church_programs').select().limit(5);

      final context = '''
Based on these ministry activities, suggest 3-5 pastoral reminders:

Tasks: ${tasks.map((t) => t['title']).join(', ')}
Programs: ${programs.map((p) => p['activity_description']).join(', ')}

Provide JSON array with: title, category, frequency, start_date, notes
Categories: ${CATEGORIES.join(', ')}
Frequencies: ${FREQUENCIES.join(', ')}
''';

      final response = await widget.gemini!.generateText(context);

      // Parse suggestions (simplified - you'd want more robust parsing)
      // For now, create sample suggestions
      setState(() {
        _aiSuggestions = [
          {
            'title': 'Prepare Sunday Sermon',
            'category': 'Sermon Preparation',
            'frequency': 'Weekly',
            'start_date': DateTime.now()
                .add(const Duration(days: 3))
                .toIso8601String(),
            'notes': 'Review scripture and outline main points',
          },
          {
            'title': 'Visit Hospital Patients',
            'category': 'Visitation',
            'frequency': 'Weekly',
            'start_date': DateTime.now()
                .add(const Duration(days: 1))
                .toIso8601String(),
            'notes': 'Check on members in local hospitals',
          },
        ];
      });
    } catch (e) {
      print('AI Error: $e');
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  /// Accept AI suggestion
  Future<void> _acceptSuggestion(Map<String, dynamic> suggestion) async {
    try {
      await _supabase.from('reminders').insert({
        ...suggestion,
        'is_active': true,
      });

      setState(() {
        _aiSuggestions.remove(suggestion);
      });

      await _fetchReminders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting suggestion: $e')),
      );
    }
  }

  /// Get category icon
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Sermon Preparation':
        return Icons.book;
      case 'Visitation':
        return Icons.person;
      case 'Counseling':
        return Icons.favorite;
      case 'Prayer & Fasting':
        return Icons.auto_awesome;
      case 'Meeting':
        return Icons.people;
      case 'Personal Devotion':
        return Icons.mic;
      default:
        return Icons.notifications;
    }
  }

  /// Get category color
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sermon Preparation':
        return Colors.indigo;
      case 'Visitation':
        return Colors.green;
      case 'Counseling':
        return Colors.pink;
      case 'Prayer & Fasting':
        return Colors.purple;
      case 'Meeting':
        return Colors.blue;
      case 'Personal Devotion':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  /// Get filtered reminders
  List<Reminder> _getFilteredReminders() {
    return _reminders
        .where((r) => _filter == 'active' ? r.isActive : !r.isActive)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReminders = _getFilteredReminders();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          'Pastoral Reminders',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.notifications, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pastoral Reminders',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Manage spiritual habits and ministry duties',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  if (widget.gemini != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateAiSuggestions,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI Suggest'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade50,
                          foregroundColor: Colors.purple.shade700,
                          elevation: 0,
                        ),
                      ),
                    ),
                  if (widget.gemini != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _resetForm();
                        setState(() => _isModalOpen = true);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Reminder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A1B9A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tabs
              Row(
                children: [
                  _buildTab('Active Reminders', 'active'),
                  const SizedBox(width: 16),
                  _buildTab('Inactive / Archived', 'inactive'),
                ],
              ),
              const SizedBox(height: 20),

              // List
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredReminders.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 180,
                          ),
                          itemCount: filteredReminders.length,
                          itemBuilder: (context, index) {
                            return _buildReminderCard(
                                filteredReminders[index]);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build tab
  Widget _buildTab(String label, String value) {
    final isSelected = _filter == value;

    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF6A1B9A) : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 80,
              color: const Color(0xFF6A1B9A),
            ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _resetForm();
              setState(() => _isModalOpen = true);
            },
            child: const Text('Create one now'),
          ),
        ],
      ),
    );
  }

  /// Build reminder card
  Widget _buildReminderCard(Reminder reminder) {
    final color = _getCategoryColor(reminder.category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(reminder.category),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.category,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        reminder.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: reminder.frequency == 'One-time'
                        ? Colors.grey.shade100
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    reminder.frequency,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: reminder.frequency == 'One-time'
                          ? Colors.grey.shade600
                          : Colors.blue.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date
            Text(
              DateFormat('EEE, MMM d, y - h:mm a').format(reminder.startDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                reminder.notes!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Spacer(),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Toggle
                InkWell(
                  onTap: () => _toggleStatus(reminder),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 24,
                        decoration: BoxDecoration(
                          color: reminder.isActive
                              ? Colors.green
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AnimatedAlign(
                          alignment: reminder.isActive
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reminder.isActive ? 'Active' : 'Paused',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _editingReminder = reminder;
                          _isModalOpen = true;
                        });
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      onPressed: () => _deleteReminder(reminder.id!),
                      icon: const Icon(Icons.delete, size: 18),
                      color: Colors.red,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
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
}
