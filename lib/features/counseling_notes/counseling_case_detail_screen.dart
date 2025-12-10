import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/counseling_case.dart';
import 'counseling_repository.dart';

class CounselingCaseDetailScreen extends StatelessWidget {
  final CounselingCase case_;
  final CounselingRepository repo;
  final VoidCallback onRefresh;

  const CounselingCaseDetailScreen({
    super.key,
    required this.case_,
    required this.repo,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Case: ${case_.personInitials}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildDetailSection('Case Type', case_.caseType),
            _buildDetailSection('Summary', case_.summary),
            _buildDetailSection('Key Issues', case_.keyIssues),
            _buildDetailSection('Scriptures Used', case_.scripturesUsed),
            _buildDetailSection('Action Steps', case_.actionSteps),
            _buildDetailSection('Prayer Points', case_.prayerPoints),
            _buildDetailSection('Additional Notes', case_.notes),
            const SizedBox(height: 12),
            _buildStatusBadge(),
            const SizedBox(height: 12),
            _buildDatesSection(),
            const SizedBox(height: 24),
            if (case_.status != 'Closed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await repo.closeCase(case_.id);
                      onRefresh();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Case marked as closed')));
                      }
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Mark as Closed'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(28)),
            child: Center(
              child: Text(case_.personInitials, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(case_.personInitials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(case_.caseType, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    switch (case_.status) {
      case 'Open':
        bgColor = Colors.blue[100]!;
        textColor = Colors.blue[900]!;
        break;
      case 'In Progress':
        bgColor = Colors.orange[100]!;
        textColor = Colors.orange[900]!;
        break;
      case 'Closed':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[900]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[900]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text('Status: ${case_.status}', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDatesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Created: ${DateFormat.yMMMd().format(case_.createdAt)}', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.alarm, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Follow-up: ${DateFormat.yMMMd().format(case_.followUpDate)}', style: const TextStyle(fontSize: 12)),
            ],
          ),
          if (case_.followUpReminder != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.notifications, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text('Reminder: ${DateFormat.yMMMd().add_jm().format(case_.followUpReminder!)}', style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ],
            ),
          ],
          if (case_.closedAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text('Closed: ${DateFormat.yMMMd().format(case_.closedAt!)}', style: const TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
