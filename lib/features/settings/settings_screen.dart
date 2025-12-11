import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Settings screen: connection test + songs JSON import
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabase = Supabase.instance.client;

  String _status = 'idle'; // idle, loading, success, error
  String _message = '';

  // Import state
  PlatformFile? _selectedFile;
  bool _importing = false;
  String _importStatusText = '';
  int _progressCurrent = 0;
  int _progressTotal = 0;
  Map<String, int>? _importResult; // {success, failed}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          'System Settings',
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
              _buildHeader(),
              const SizedBox(height: 16),
              _buildConnectionPanel(),
              const SizedBox(height: 16),
              _buildImportPanel(),
            ],
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.settings, size: 28, color: Color(0xFF1F2558)),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Settings',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2558),
              ),
            ),
            Text(
              'Manage application configuration and connections',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Connection panel
  Widget _buildConnectionPanel() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Database Connection',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Connection info (basic)
            Row(
              children: [
                _infoChip('Client', 'Supabase Flutter'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _status == 'loading' ? null : _testConnection,
                  icon: _status == 'loading'
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.link),
                  label: const Text('Test Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                if (_status == 'success')
                  _statusBanner(Icons.check_circle, Colors.green, _message.isEmpty ? 'Connection successful' : _message)
                else if (_status == 'error')
                  _statusBanner(Icons.error, Colors.red, _message.isEmpty ? 'Connection failed' : _message),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Checks church_programs and songs tables; surfaces RLS/missing table hints.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  // Import panel
  Widget _buildImportPanel() {
    final hasFile = _selectedFile != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_open, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Data Management',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Import methodist_songs_flat.json to populate Hymns. Upload in batches of 50. Do not close until completed.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            if (_importResult != null)
              _successBox('${_importResult!['success'] ?? 0} songs uploaded${(_importResult!['failed'] ?? 0) > 0 ? ' with ${_importResult!['failed']} failures' : ''}'),

            const SizedBox(height: 8),

            if (!_importing && !hasFile) _buildSelectFileRow(),
            if (!_importing && hasFile) _buildReadyRow(),
            if (_importing) _buildImportingRow(),

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'This will upload data to the songs table. Ensure the table exists and policies allow inserts.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _successBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.green.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFileRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select file source:',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _pickJson,
              icon: const Icon(Icons.phone_android),
              label: const Text('Local Device'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade800,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _pickFromDrive,
              icon: const Icon(Icons.cloud),
              label: const Text('Google Drive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _pickFromOneDrive,
              icon: const Icon(Icons.cloud_outlined),
              label: const Text('OneDrive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo.shade700,
                side: BorderSide(color: Colors.indigo.shade200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: _clearSongs,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Clear All Songs'),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Choose methodist_songs_flat.json from your device or cloud storage.',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildReadyRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile?.name ?? 'file',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(_selectedFile?.size ?? 0) ~/ 1024} KB',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _selectedFile = null;
                  _importResult = null;
                  _importStatusText = '';
                }),
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _startImport,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Import'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () => setState(() {
                _selectedFile = null;
                _importResult = null;
                _importStatusText = '';
              }),
              child: const Text('Cancel'),
            ),
          ],
        ),
        if (_importStatusText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            _importStatusText,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ],
    );
  }

  Widget _buildImportingRow() {
    final percent = _progressTotal == 0
        ? 0
        : ((_progressCurrent / _progressTotal) * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _importStatusText,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Text('$percent%'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percent / 100),
        const SizedBox(height: 4),
        Text(
          'Processed $_progressCurrent of $_progressTotal items',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // --- Logic ---
  Future<void> _testConnection() async {
    setState(() {
      _status = 'loading';
      _message = '';
    });

    try {
      // check church_programs
        final programs = await _supabase.from('church_programs').select('id').limit(1);
      if (programs is PostgrestException) throw programs;

      // check songs
      final songs = await _supabase.from('songs').select('id').limit(1);
      if (songs is PostgrestException) throw songs;

      setState(() {
        _status = 'success';
        _message = 'Connection successful! Database reachable.';
      });
    } catch (err) {
      final msg = _mapError(err);
      setState(() {
        _status = 'error';
        _message = msg;
      });
    }
  }

  String _mapError(Object err) {
    if (err is PostgrestException) {
      if (err.code == '42P01') {
        final missing = err.message.contains('songs') ? 'songs' : 'church_programs';
        return "Table Error: '$missing' table not found. Run the SQL setup.";
      }
      if (err.code == 'PGRST301') {
        return 'Permission Error: RLS policies might be blocking access.';
      }
      return err.message;
    }
    final text = err.toString();
    if (text.contains('Failed host lookup') || text.contains('fetch')) {
      return 'Network Error: Could not reach Supabase. Check internet or URL.';
    }
    return text;
  }

  Future<void> _pickJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _importResult = null;
          _importStatusText = 'File ready to process.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File pick error: $e')),
      );
    }
  }

  Future<void> _pickFromDrive() async {
    try {
      // FilePicker on mobile can access cloud storage providers
      // if they're registered as document providers (Google Drive app)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _importResult = null;
          _importStatusText = 'File ready to process from Google Drive.';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Make sure Google Drive app is installed to access cloud files.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drive access error: $e')),
      );
    }
  }

  Future<void> _pickFromOneDrive() async {
    try {
      // FilePicker on mobile can access cloud storage providers
      // if they're registered as document providers (OneDrive app)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _importResult = null;
          _importStatusText = 'File ready to process from OneDrive.';
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Make sure OneDrive app is installed to access cloud files.'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OneDrive access error: $e')),
      );
    }
  }

  Future<void> _startImport() async {
    if (_selectedFile?.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
      return;
    }

    setState(() {
      _importing = true;
      _importStatusText = 'Reading file...';
      _progressCurrent = 0;
      _progressTotal = 0;
      _importResult = null;
    });

    try {
      final text = utf8.decode(_selectedFile!.bytes!);
      _importStatusText = 'Parsing JSON...';
      dynamic jsonData;
      try {
        jsonData = json.decode(text);
      } catch (_) {
        throw Exception('Invalid JSON syntax.');
      }

      _importStatusText = 'Scanning songs...';
      final songs = _findSongs(jsonData);
      final total = songs.length;
      if (total == 0) {
        throw Exception('No songs found in file.');
      }
      setState(() => _progressTotal = total);

      // Check table exists
      await _supabase.from('songs').select('id').limit(1);

      const batchSize = 50;
      int success = 0;
      int failed = 0;

      for (int i = 0; i < total; i += batchSize) {
        setState(() => _importStatusText = 'Uploading batch ${i ~/ batchSize + 1} of ${ (total / batchSize).ceil()}...');
        final batch = songs
            .skip(i)
            .take(batchSize)
            .toList();

        final response = await _supabase.from('songs').upsert(batch);
        if (response is PostgrestException) {
          failed += batch.length;
          if (response.code == '42P01') {
            throw Exception("'songs' table missing. Stopping import.");
          }
        } else {
          success += batch.length;
        }

        setState(() => _progressCurrent = (i + batch.length).clamp(0, total));
        await Future.delayed(const Duration(milliseconds: 10));
      }

      setState(() {
        _importResult = {'success': success, 'failed': failed};
        _importStatusText = 'Import complete!';
        _selectedFile = null;
      });
    } catch (e) {
      setState(() => _importStatusText = 'Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      setState(() => _importing = false);
    }
  }

  Future<void> _clearSongs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ALL songs?'),
        content: const Text('This will remove every song from the database.'),
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

    if (confirm == true) {
      try {
        setState(() {
          _importing = true;
          _importStatusText = 'Clearing songs...';
        });
        await _supabase.from('songs').delete().neq('id', 0);
        setState(() {
          _importStatusText = 'Database cleared.';
          _importResult = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing: $e')),
        );
      } finally {
        setState(() => _importing = false);
      }
    }
  }

  List<Map<String, dynamic>> _findSongs(dynamic obj, [String? parentKey, int depth = 0]) {
    if (depth > 5 || obj == null) return [];

    if (obj is List) {
      if (obj.isNotEmpty && obj.first is Map &&
          ((obj.first as Map).containsKey('title') || (obj.first as Map).containsKey('lyrics') || (obj.first as Map).containsKey('number'))) {
        return obj.asMap().entries.map((entry) {
          final s = entry.value as Map;
          String? collection = s['collection'];
          if ((collection == null || collection.isEmpty) && parentKey != null) {
            final k = parentKey.toUpperCase();
            if (k.contains('MHB')) collection = 'MHB';
            else if (k.contains('CAN') && !k.contains('CANTICLE')) collection = 'CAN';
            else if (k.contains('CANTICLE')) collection = 'CANTICLES_EN';
            else collection = parentKey;
          }
          final fallbackId = DateTime.now().millisecondsSinceEpoch + entry.key;
          return {
            'id': s['id'] ?? fallbackId,
            'collection': collection ?? 'General',
            'code': s['code'] ?? 'GEN${s['number'] ?? entry.key}',
            'number': s['number'] ?? 0,
            'title': s['title'] ?? 'Untitled Song',
            'raw_title': s['raw_title'],
            'lyrics': s['lyrics'] ?? '',
            'author': s['author'],
            'copyright': s['copyright'],
            'tags': s['tags'],
            'reference_number': s['reference_number'],
          };
        }).toList();
      }
      return obj.expand((e) => _findSongs(e, parentKey, depth + 1)).toList();
    }

    if (obj is Map) {
      return obj.entries
          .expand((entry) => _findSongs(entry.value, entry.key, depth + 1))
          .toList();
    }

    return [];
  }
}
