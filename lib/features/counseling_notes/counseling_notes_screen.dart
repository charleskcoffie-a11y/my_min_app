import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/counseling_case.dart';
// import '../../core/pdf_export_service.dart';
import 'counseling_repository.dart';
import 'counseling_case_detail_screen.dart';
import 'advanced_filter_screen.dart';
import 'staff_management_screen.dart';
// import 'package:printing/printing.dart';

class CounselingNotesScreen extends StatefulWidget {
  const CounselingNotesScreen({super.key});

  @override
  State<CounselingNotesScreen> createState() => _CounselingNotesScreenState();
}

class _CounselingNotesScreenState extends State<CounselingNotesScreen> {
  final _repo = CounselingRepository();
  bool _loading = true;
  List<CounselingCase> _allCases = [];
  List<CounselingCase> _filteredCases = [];
  String _statusFilter = 'All';
  String _searchQuery = '';

  // static const List<String> caseTypes = [
  //   'Marriage',
  //   'Family',
  //   'Addiction',
  //   'Youth',
  //   'Bereavement',
  //   'Spiritual',
  //   'Other',
  // ];

  static const List<String> statuses = ['Open', 'In Progress', 'Closed'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cases = await _repo.getAllCases();
      setState(() => _allCases = cases);
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading cases: $e')));
      }
    }
    setState(() => _loading = false);
      if (!mounted) return;
  }

  void _applyFilters() {
    _filteredCases = _allCases;

    // Filter by status
    if (_statusFilter != 'All') {
      _filteredCases = _filteredCases.where((c) => c.status == _statusFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      _filteredCases = _filteredCases
          .where((c) =>
              c.personInitials.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.caseType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.summary.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by follow-up date
    _filteredCases.sort((a, b) => a.followUpDate.compareTo(b.followUpDate));
  }

  void _showAddCaseSheet() {
    _showCaseForm(null);
  }

  void _showCaseForm(CounselingCase? existingCase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => CounselingCaseFormSheet(
        existingCase: existingCase,
        onSave: (caseData) async {
          try {
            if (existingCase == null) {
              await _repo.createCase(
                personInitials: caseData['personInitials'],
                caseType: caseData['caseType'],
                summary: caseData['summary'],
                keyIssues: caseData['keyIssues'],
                scripturesUsed: caseData['scripturesUsed'],
                actionSteps: caseData['actionSteps'],
                prayerPoints: caseData['prayerPoints'],
                followUpDate: caseData['followUpDate'],
                followUpReminder: caseData['followUpReminder'],
                notes: caseData['notes'],
              );
            } else {
              await _repo.updateCase(
                id: existingCase.id,
                personInitials: caseData['personInitials'],
                caseType: caseData['caseType'],
                summary: caseData['summary'],
                keyIssues: caseData['keyIssues'],
                scripturesUsed: caseData['scripturesUsed'],
                actionSteps: caseData['actionSteps'],
                prayerPoints: caseData['prayerPoints'],
                followUpDate: caseData['followUpDate'],
                followUpReminder: caseData['followUpReminder'],
                notes: caseData['notes'],
              );
            }
            if (!mounted) return;
            Navigator.pop(context);
            await _load();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Case ${existingCase == null ? 'created' : 'updated'} successfully')));
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidential Counseling Notes'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdvancedCounselingFilterScreen(
                    allCases: _allCases,
                    repo: _repo,
                    onRefresh: _load,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Advanced Filters & Analytics',
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StaffManagementScreen()));
            },
            icon: const Icon(Icons.group),
            tooltip: 'Staff Management',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCaseSheet,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by initials, type, or summary...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'All'),
                      ...statuses.map((s) => _buildFilterChip(s, s)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Cases List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              _allCases.isEmpty ? 'No cases yet' : 'No cases match your filter',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredCases.length,
                        itemBuilder: (_, i) => _buildCaseCard(_filteredCases[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _statusFilter = value);
          _applyFilters();
        },
      ),
    );
  }

  Widget _buildCaseCard(CounselingCase case_) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _statusColor(case_.status),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              case_.personInitials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text('${case_.personInitials} — ${case_.caseType}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(case_.summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              'Follow-up: ${case_.followUpDateDisplay} • ${case_.status}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              child: const Text('View'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CounselingCaseDetailScreen(case_: case_, repo: _repo, onRefresh: _load),
                  ),
                );
              },
            ),
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _showCaseForm(case_),
            ),
            if (case_.status != 'Closed')
              PopupMenuItem(
                child: const Text('Mark as Closed'),
                onTap: () async {
                  try {
                    await _repo.closeCase(case_.id);
                    await _load();
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete case?'),
                    content: const Text('This action cannot be undone. This case will be permanently deleted.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () async {
                          try {
                            await _repo.deleteCase(case_.id);
                            if (mounted) Navigator.pop(context);
                            await _load();
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CounselingCaseDetailScreen(case_: case_, repo: _repo, onRefresh: _load),
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class CounselingCaseFormSheet extends StatefulWidget {
  final CounselingCase? existingCase;
  final Function(Map<String, dynamic>) onSave;

  const CounselingCaseFormSheet({super.key, this.existingCase, required this.onSave});

  @override
  State<CounselingCaseFormSheet> createState() => _CounselingCaseFormSheetState();
}

class _CounselingCaseFormSheetState extends State<CounselingCaseFormSheet> {
  late TextEditingController _initialsCtrl;
  late TextEditingController _summaryCtrl;
  late TextEditingController _keyIssuesCtrl;
  late TextEditingController _scripturesCtrl;
  late TextEditingController _actionStepsCtrl;
  late TextEditingController _prayerPointsCtrl;
  late TextEditingController _notesCtrl;

  String _caseType = 'Other';
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 7));
  DateTime? _followUpReminder;

  @override
  void initState() {
    super.initState();
    _initialsCtrl = TextEditingController(text: widget.existingCase?.personInitials ?? '');
    _summaryCtrl = TextEditingController(text: widget.existingCase?.summary ?? '');
    _keyIssuesCtrl = TextEditingController(text: widget.existingCase?.keyIssues ?? '');
    _scripturesCtrl = TextEditingController(text: widget.existingCase?.scripturesUsed ?? '');
    _actionStepsCtrl = TextEditingController(text: widget.existingCase?.actionSteps ?? '');
    _prayerPointsCtrl = TextEditingController(text: widget.existingCase?.prayerPoints ?? '');
    _notesCtrl = TextEditingController(text: widget.existingCase?.notes ?? '');
    _caseType = widget.existingCase?.caseType ?? 'Other';
    _followUpDate = widget.existingCase?.followUpDate ?? DateTime.now().add(const Duration(days: 7));
    _followUpReminder = widget.existingCase?.followUpReminder;
  }

  @override
  void dispose() {
    _initialsCtrl.dispose();
    _summaryCtrl.dispose();
    _keyIssuesCtrl.dispose();
    _scripturesCtrl.dispose();
    _actionStepsCtrl.dispose();
    _prayerPointsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(context: context, initialDate: _followUpDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (picked != null) setState(() => _followUpDate = picked);
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(context: context, initialDate: _followUpReminder ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_followUpReminder ?? DateTime.now()));
    if (time != null) setState(() => _followUpReminder = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Counseling Case', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: _initialsCtrl, decoration: const InputDecoration(labelText: 'Person Initials (e.g., J.S.)', hintText: 'Initials only')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _caseType,
                items: const [
                  DropdownMenuItem(value: 'Marriage', child: Text('Marriage')),
                  DropdownMenuItem(value: 'Family', child: Text('Family')),
                  DropdownMenuItem(value: 'Addiction', child: Text('Addiction')),
                  DropdownMenuItem(value: 'Youth', child: Text('Youth')),
                  DropdownMenuItem(value: 'Bereavement', child: Text('Bereavement')),
                  DropdownMenuItem(value: 'Spiritual', child: Text('Spiritual')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) { if (v != null) setState(() => _caseType = v); },
                decoration: const InputDecoration(labelText: 'Case Type'),
              ),
              const SizedBox(height: 12),
              TextField(controller: _summaryCtrl, decoration: const InputDecoration(labelText: 'Summary', hintText: 'Brief overview'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: _keyIssuesCtrl, decoration: const InputDecoration(labelText: 'Key Issues', hintText: 'Main concerns'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: _scripturesCtrl, decoration: const InputDecoration(labelText: 'Scriptures Used', hintText: 'Bible passages discussed'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: _actionStepsCtrl, decoration: const InputDecoration(labelText: 'Action Steps', hintText: 'Recommendations'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: _prayerPointsCtrl, decoration: const InputDecoration(labelText: 'Prayer Points', hintText: 'Key prayer focuses'), maxLines: 2),
              const SizedBox(height: 12),
              TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Additional Notes', hintText: 'Private notes'), maxLines: 2),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFollowUpDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text('Follow-up: ${DateFormat.yMd().format(_followUpDate)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: _followUpReminder != null, onChanged: (v) { setState(() { _followUpReminder = v == true ? DateTime.now().add(const Duration(hours: 1)) : null; }); }),
                  const SizedBox(width: 8),
                  const Text('Set reminder'),
                  const Spacer(),
                  if (_followUpReminder != null)
                    TextButton(onPressed: _pickReminder, child: Text(DateFormat.yMd().add_jm().format(_followUpReminder!)))
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_initialsCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Initials required')));
                      return;
                    }
                    widget.onSave({
                      'personInitials': _initialsCtrl.text.trim(),
                      'caseType': _caseType,
                      'summary': _summaryCtrl.text.trim(),
                      'keyIssues': _keyIssuesCtrl.text.trim(),
                      'scripturesUsed': _scripturesCtrl.text.trim(),
                      'actionSteps': _actionStepsCtrl.text.trim(),
                      'prayerPoints': _prayerPointsCtrl.text.trim(),
                      'followUpDate': _followUpDate,
                      'followUpReminder': _followUpReminder,
                      'notes': _notesCtrl.text.trim(),
                    });
                  },
                  child: const Text('Save Case'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
