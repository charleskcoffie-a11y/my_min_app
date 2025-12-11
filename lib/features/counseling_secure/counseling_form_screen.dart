import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/counseling_session.dart';
import '../../repositories/counseling_repository.dart';

/// Form for creating/editing counseling sessions
class CounselingFormScreen extends StatefulWidget {
  final CounselingSession? session;

  const CounselingFormScreen({super.key, this.session});

  @override
  State<CounselingFormScreen> createState() => _CounselingFormScreenState();
}

class _CounselingFormScreenState extends State<CounselingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = CounselingRepository();

  late TextEditingController _initialsController;
  late TextEditingController _summaryController;
  late TextEditingController _keyIssuesController;
  late TextEditingController _scripturesController;
  late TextEditingController _actionStepsController;
  late TextEditingController _prayerPointsController;

  String _selectedCaseType = CounselingConstants.caseTypes.first;
  String _selectedStatus = CounselingConstants.statuses.first;
  DateTime? _followUpDate;
  bool _createReminder = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _initialsController = TextEditingController(text: widget.session?.initials ?? '');
    _summaryController = TextEditingController(text: widget.session?.summary ?? '');
    _keyIssuesController = TextEditingController(text: widget.session?.keyIssues ?? '');
    _scripturesController = TextEditingController(text: widget.session?.scripturesUsed ?? '');
    _actionStepsController = TextEditingController(text: widget.session?.actionSteps ?? '');
    _prayerPointsController = TextEditingController(text: widget.session?.prayerPoints ?? '');

    // Pre-fill data if editing
    if (widget.session != null) {
      _selectedCaseType = widget.session!.caseType;
      _selectedStatus = widget.session!.status;
      _followUpDate = widget.session!.followUpDate;
    }
  }

  @override
  void dispose() {
    _initialsController.dispose();
    _summaryController.dispose();
    _keyIssuesController.dispose();
    _scripturesController.dispose();
    _actionStepsController.dispose();
    _prayerPointsController.dispose();
    super.dispose();
  }

  /// Save the session
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final sessionData = CounselingSession(
        id: widget.session?.id ?? '',
        initials: _initialsController.text.toUpperCase().trim(),
        caseType: _selectedCaseType,
        summary: _summaryController.text.trim(),
        keyIssues: _keyIssuesController.text.isEmpty ? null : _keyIssuesController.text.trim(),
        scripturesUsed: _scripturesController.text.isEmpty ? null : _scripturesController.text.trim(),
        actionSteps: _actionStepsController.text.isEmpty ? null : _actionStepsController.text.trim(),
        prayerPoints: _prayerPointsController.text.isEmpty ? null : _prayerPointsController.text.trim(),
        followUpDate: _followUpDate,
        status: _selectedStatus,
        createdAt: widget.session?.createdAt ?? DateTime.now(),
      );

      if (widget.session == null) {
        // Create new
        await _repository.insertSession(sessionData);
      } else {
        // Update existing
        await _repository.updateSession(widget.session!.id, sessionData);
      }

      // Create reminder if requested
      if (_createReminder && _followUpDate != null) {
        await _repository.createReminder(
          initials: _initialsController.text.toUpperCase().trim(),
          caseType: _selectedCaseType,
          followUpDate: _followUpDate!,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.session == null
                ? 'Counseling session created'
                : 'Counseling session updated'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Pick follow-up date
  Future<void> _pickFollowUpDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_followUpDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _followUpDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          widget.session == null ? 'New Counseling Session' : 'Edit Session',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Initials
              _buildSectionTitle('Subject Information'),
              TextFormField(
                controller: _initialsController,
                decoration: InputDecoration(
                  labelText: 'Subject Initials *',
                  helperText: 'Use initials only for privacy',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter initials';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Case Type
              DropdownButtonFormField<String>(
                value: _selectedCaseType,
                decoration: InputDecoration(
                  labelText: 'Case Type *',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: CounselingConstants.caseTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCaseType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status *',
                  prefixIcon: const Icon(Icons.assignment_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: CounselingConstants.statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                },
              ),
              const SizedBox(height: 16),

              // Follow-up Date
              InkWell(
                onTap: _pickFollowUpDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Follow-up Date (Optional)',
                    prefixIcon: const Icon(Icons.event),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: Text(
                    _followUpDate == null
                        ? 'No follow-up scheduled'
                        : DateFormat('MMM d, y - h:mm a').format(_followUpDate!),
                  ),
                ),
              ),
              if (_followUpDate != null) ...[
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _createReminder,
                  onChanged: (value) {
                    setState(() => _createReminder = value ?? false);
                  },
                  title: const Text('Create reminder for follow-up'),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
              const SizedBox(height: 24),

              // Summary
              _buildSectionTitle('Session Details'),
              TextFormField(
                controller: _summaryController,
                decoration: InputDecoration(
                  labelText: 'Summary *',
                  hintText: 'Brief overview of the counseling session',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a summary';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Key Issues
              TextFormField(
                controller: _keyIssuesController,
                decoration: InputDecoration(
                  labelText: 'Key Issues (Optional)',
                  hintText: 'Main concerns or challenges discussed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Scriptures Used
              TextFormField(
                controller: _scripturesController,
                decoration: InputDecoration(
                  labelText: 'Scriptures Used (Optional)',
                  hintText: 'Biblical references shared during session',
                  prefixIcon: const Icon(Icons.menu_book),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Action Steps
              _buildSectionTitle('Action Plan', color: Colors.blue),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: TextFormField(
                  controller: _actionStepsController,
                  decoration: const InputDecoration(
                    labelText: 'Action Steps (Optional)',
                    hintText: 'Practical steps or commitments made',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 24),

              // Prayer Points
              _buildSectionTitle('Prayer Points', color: Colors.purple),
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.2)),
                ),
                child: TextFormField(
                  controller: _prayerPointsController,
                  decoration: const InputDecoration(
                    labelText: 'Prayer Points (Optional)',
                    hintText: 'Specific prayer requests or concerns',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.session == null ? 'Create Session' : 'Update Session',
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
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color ?? const Color(0xFF1F2558),
        ),
      ),
    );
  }
}
