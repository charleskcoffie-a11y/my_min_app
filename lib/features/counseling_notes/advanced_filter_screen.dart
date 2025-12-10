import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/counseling_case.dart';
import '../../core/advanced_filter_service.dart';
import '../../core/pdf_export_service.dart';
import 'counseling_repository.dart';
import 'counseling_case_detail_screen.dart';
import 'package:printing/printing.dart';

class AdvancedCounselingFilterScreen extends StatefulWidget {
  final List<CounselingCase> allCases;
  final CounselingRepository repo;
  final VoidCallback onRefresh;

  const AdvancedCounselingFilterScreen({
    super.key,
    required this.allCases,
    required this.repo,
    required this.onRefresh,
  });

  @override
  State<AdvancedCounselingFilterScreen> createState() => _AdvancedCounselingFilterScreenState();
}

class _AdvancedCounselingFilterScreenState extends State<AdvancedCounselingFilterScreen> {
  String? _selectedCaseType;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showStats = false;

  static const List<String> caseTypes = ['Marriage', 'Family', 'Addiction', 'Youth', 'Bereavement', 'Spiritual', 'Other'];
  static const List<String> statuses = ['Open', 'In Progress', 'Closed'];

  List<CounselingCase> get _filteredCases {
    final options = AdvancedFilterOptions(
      caseType: _selectedCaseType,
      status: _selectedStatus,
      dateRange: _startDate != null && _endDate != null ? DateRange(start: _startDate!, end: _endDate!) : null,
    );
    return AdvancedFilterService.applyFilters(widget.allCases, options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Filters & Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Section
            _buildFilterCard(),
            const SizedBox(height: 16),

            // Statistics Section
            if (_showStats) ...[
              _buildStatisticsCard(),
              const SizedBox(height: 16),
            ],

            // Toggle Stats Button
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => _showStats = !_showStats),
                  icon: Icon(_showStats ? Icons.visibility_off : Icons.visibility),
                  label: Text(_showStats ? 'Hide Analytics' : 'Show Analytics'),
                ),
                const Spacer(),
                if (_filteredCases.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _exportToPdf,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export PDF'),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Results
            const Text('Results', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_filteredCases.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No cases match your filters',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ..._filteredCases.map((case_) => _buildCaseCard(case_)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCaseType,
              decoration: const InputDecoration(labelText: 'Case Type', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...caseTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))),
              ],
              onChanged: (v) => setState(() => _selectedCaseType = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))),
              ],
              onChanged: (v) => setState(() => _selectedStatus = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _startDate = date);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate != null ? DateFormat.yMd().format(_startDate!) : 'Start Date'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) setState(() => _endDate = date);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate != null ? DateFormat.yMd().format(_endDate!) : 'End Date'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _selectedCaseType = null;
                  _selectedStatus = null;
                  _startDate = null;
                  _endDate = null;
                }),
                child: const Text('Reset Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final allCases = widget.allCases;
    final stats = <String, int>{
      'Total Cases': allCases.length,
      'Open': AdvancedFilterService.countByStatus(allCases, 'Open'),
      'In Progress': AdvancedFilterService.countByStatus(allCases, 'In Progress'),
      'Closed': AdvancedFilterService.countByStatus(allCases, 'Closed'),
      'Due for Follow-up': AdvancedFilterService.getDueForFollowUp(allCases).length,
    };

    final grouped = AdvancedFilterService.groupByCaseType(allCases);

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Analytics', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stats.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue[200]!)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text(e.key, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Cases by Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...grouped.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(e.key, style: const TextStyle(fontSize: 11))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue[200], borderRadius: BorderRadius.circular(12)),
                      child: Text(e.value.length.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
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
        subtitle: Text('Follow-up: ${DateFormat.yMd().format(case_.followUpDate)} • ${case_.status}'),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              child: const Text('View'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CounselingCaseDetailScreen(case_: case_, repo: widget.repo, onRefresh: widget.onRefresh),
                  ),
                );
              },
            ),
            PopupMenuItem(
              child: const Text('Export PDF'),
              onTap: () => _exportCasePdf(case_),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final doc = pw.Document();
      for (final case_ in _filteredCases) {
        await PdfExportService.generateCaseReport(case_);
        // If you want to add a page from another document, you need to rebuild it. This is a placeholder for correct PDF merging logic.
        // doc.addPage(casePdf.pages.first); // Incorrect usage, 'pages' does not exist.
      }
      await Printing.layoutPdf(onLayout: (_) async => doc.save());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export error: $e')));
    }
  }

  Future<void> _exportCasePdf(CounselingCase case_) async {
    try {
      final doc = await PdfExportService.generateCaseReport(case_);
      await Printing.layoutPdf(onLayout: (_) async => doc.save());
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export error: $e')));
    }
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
