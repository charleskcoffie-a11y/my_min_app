import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/counseling_case.dart';

class PdfExportService {
  static Future<pw.Document> generateCaseReport(CounselingCase case_) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Counseling Case Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'CONFIDENTIAL — Personal Use Only',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
          ),
          pw.Divider(),
          pw.SizedBox(height: 12),
          _buildSection('Case Information', [
            _buildRow('Person Initials', case_.personInitials),
            _buildRow('Case Type', case_.caseType),
            _buildRow('Status', case_.status),
            _buildRow('Created', DateFormat.yMMMd().format(case_.createdAt)),
            _buildRow('Follow-up Date', DateFormat.yMMMd().format(case_.followUpDate)),
            if (case_.closedAt != null) _buildRow('Closed', DateFormat.yMMMd().format(case_.closedAt!)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('Summary', [
            pw.Text(case_.summary, style: const pw.TextStyle(fontSize: 11)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('Key Issues', [
            pw.Text(case_.keyIssues, style: const pw.TextStyle(fontSize: 11)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('Scriptures Used', [
            pw.Text(case_.scripturesUsed, style: const pw.TextStyle(fontSize: 11)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('Action Steps', [
            pw.Text(case_.actionSteps, style: const pw.TextStyle(fontSize: 11)),
          ]),
          pw.SizedBox(height: 12),
          _buildSection('Prayer Points', [
            pw.Text(case_.prayerPoints, style: const pw.TextStyle(fontSize: 11)),
          ]),
          if (case_.notes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildSection('Additional Notes', [
              pw.Text(case_.notes, style: const pw.TextStyle(fontSize: 11)),
            ]),
          ],
          pw.SizedBox(height: 24),
        ],
      ),
    );
    return doc;
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(children: children),
        ),
      ],
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
