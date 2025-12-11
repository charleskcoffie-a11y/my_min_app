import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/sermon.dart';
import '../../repositories/sermon_repository.dart';
import '../../core/gemini_service.dart';

/// 12-Point Methodist Sermon Editor
class SermonEditorScreen extends StatefulWidget {
  final Sermon? sermon;

  const SermonEditorScreen({super.key, this.sermon});

  @override
  State<SermonEditorScreen> createState() => _SermonEditorScreenState();
}

class _SermonEditorScreenState extends State<SermonEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = SermonRepository();
  late final GeminiService _gemini;

  bool _isSaving = false;
  bool _isGenerating = false;

  late TextEditingController _titleController;
  late TextEditingController _themeController;
  late TextEditingController _scriptureController;
  late TextEditingController _introductionController;
  late TextEditingController _backgroundController;
  late TextEditingController _point1Controller;
  late TextEditingController _point2Controller;
  late TextEditingController _point3Controller;
  late TextEditingController _gospelController;
  late TextEditingController _conclusionController;
  late TextEditingController _altarCallController;
  late TextEditingController _propositionController;

  List<TextEditingController> _applicationControllers = [];
  List<TextEditingController> _prayerControllers = [];

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  /// Initialize all controllers
  void _initControllers() {
    final sermon = widget.sermon;

    _titleController = TextEditingController(text: sermon?.title ?? '');
    _themeController = TextEditingController(text: sermon?.theme ?? '');
    _scriptureController = TextEditingController(text: sermon?.mainText ?? '');
    _introductionController = TextEditingController(text: sermon?.introduction ?? '');
    _backgroundController = TextEditingController(text: sermon?.backgroundContext ?? '');
    _point1Controller = TextEditingController(text: sermon?.mainPoints[0]?['content'] ?? '');
    _point2Controller = TextEditingController(text: sermon?.mainPoints[1]?['content'] ?? '');
    _point3Controller = TextEditingController(text: sermon?.mainPoints[2]?['content'] ?? '');
    _gospelController = TextEditingController(text: sermon?.gospelConnection ?? '');
    _conclusionController = TextEditingController(text: sermon?.conclusion ?? '');
    _altarCallController = TextEditingController(text: sermon?.altarCall ?? '');
    _propositionController = TextEditingController(text: sermon?.proposition ?? '');

    // Application points
    _applicationControllers = (sermon?.applications ?? [])
        .map((app) => TextEditingController(text: app))
        .toList();

    // Prayer points
    _prayerControllers = (sermon?.prayerPoints ?? [])
        .map((prayer) => TextEditingController(text: prayer))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _themeController.dispose();
    _scriptureController.dispose();
    _introductionController.dispose();
    _backgroundController.dispose();
    _point1Controller.dispose();
    _point2Controller.dispose();
    _point3Controller.dispose();
    _gospelController.dispose();
    _conclusionController.dispose();
    _altarCallController.dispose();
    _propositionController.dispose();

    for (var controller in _applicationControllers) {
      controller.dispose();
    }
    for (var controller in _prayerControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  /// Add application point
  void _addApplication() {
    setState(() {
      _applicationControllers.add(TextEditingController());
    });
  }

  /// Remove application point
  void _removeApplication(int index) {
    _applicationControllers[index].dispose();
    setState(() {
      _applicationControllers.removeAt(index);
    });
  }

  /// Add prayer point
  void _addPrayer() {
    setState(() {
      _prayerControllers.add(TextEditingController());
    });
  }

  /// Remove prayer point
  void _removePrayer(int index) {
    _prayerControllers[index].dispose();
    setState(() {
      _prayerControllers.removeAt(index);
    });
  }

  /// Generate entire sermon outline with AI
  Future<void> _generateFullOutline() async {
    if (_titleController.text.isEmpty || _scriptureController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Title and Scripture first')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // This would call Gemini API - for now showing placeholder
      final prompt = '''
You are a Methodist pastor. Create a complete sermon outline for:
Title: ${_titleController.text}
Scripture: ${_scriptureController.text}
Theme: ${_themeController.text}

Provide a comprehensive 12-point Methodist sermon with:
1. Introduction
2. Background context
3. Three main points with explanations
4. Practical applications (3-5 points)
5. Gospel connection
6. Conclusion
7. Prayer points (3-5 points)
8. Altar call

Format as clear, pastoral, and practical for a Methodist audience.
''';

      // In real implementation, await _gemini.generateText(prompt)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI generation would populate the form')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  /// Save sermon
  Future<void> _saveSermon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final sermon = Sermon(
        id: widget.sermon?.id,
        title: _titleController.text,
        theme: _themeController.text,
        mainText: _scriptureController.text,
        introduction: _introductionController.text,
        backgroundContext: _backgroundController.text,
        mainPoints: [
          {'title': 'Explain', 'content': _point1Controller.text},
          {'title': 'Apply', 'content': _point2Controller.text},
          {'title': 'Transform', 'content': _point3Controller.text},
        ],
        applications: _applicationControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        gospelConnection: _gospelController.text,
        conclusion: _conclusionController.text,
        prayerPoints: _prayerControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
        altarCall: _altarCallController.text,
        proposition: _propositionController.text,
      );

      if (widget.sermon == null) {
        await _repository.insertSermon(sermon);
      } else {
        await _repository.updateSermon(sermon);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.sermon == null ? 'Sermon created' : 'Sermon updated'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          widget.sermon == null ? 'New Sermon' : 'Edit Sermon',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateFullOutline,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: const Text('AI Generate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6A1B9A),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'THE METHODIST CHURCH GHANA\nNORTH AMERICA DIOCESE\nCANADA CIRCUIT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: '1. Sermon Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  validator: (value) => value?.isEmpty ?? true ? 'Title required' : null,
                ),
                const SizedBox(height: 16),

                // 2. Scripture and Theme
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _scriptureController,
                        decoration: InputDecoration(
                          labelText: '2. Scripture',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _themeController,
                        decoration: InputDecoration(
                          labelText: 'Theme',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Introduction
                _buildSection(
                  '3. Introduction',
                  'Greeting, problem statement, big idea',
                  _introductionController,
                ),
                const SizedBox(height: 16),

                // 4. Background
                _buildSection(
                  '4. Background / Context',
                  'Historical and cultural context',
                  _backgroundController,
                ),
                const SizedBox(height: 24),

                // 5, 6, 7. Main Points
                _buildMainPoints(),
                const SizedBox(height: 24),

                // 8. Applications
                _buildApplications(),
                const SizedBox(height: 24),

                // 9. Gospel Connection
                _buildSection(
                  '9. Gospel Connection',
                  'How does Jesus fulfill this?',
                  _gospelController,
                ),
                const SizedBox(height: 16),

                // 10. Conclusion
                _buildSection(
                  '10. Conclusion',
                  'Summarize and reinforce',
                  _conclusionController,
                ),
                const SizedBox(height: 24),

                // 11. Prayer Points
                _buildPrayerPoints(),
                const SizedBox(height: 24),

                // 12. Altar Call
                _buildSection(
                  '12. Altar Call / Response',
                  'Invitation to salvation or recommitment',
                  _altarCallController,
                  color: Colors.red.shade50,
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSermon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Save Sermon',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
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

  /// Build section with label and textarea
  Widget _buildSection(
    String label,
    String hint,
    TextEditingController controller, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (color ?? Colors.blue.shade50).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2558),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main points section
  Widget _buildMainPoints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '5, 6, 7. Main Points',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMainPoint('5. Explain the Text', _point1Controller),
          const SizedBox(height: 16),
          _buildMainPoint('6. Show How It Applies', _point2Controller),
          const SizedBox(height: 16),
          _buildMainPoint('7. Call to Transformation', _point3Controller),
        ],
      ),
    );
  }

  /// Build single main point
  Widget _buildMainPoint(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  /// Build applications section
  Widget _buildApplications() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '8. Practical Applications',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _addApplication,
                icon: const Icon(Icons.add),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _applicationControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _applicationControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Action step ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeApplication(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 8),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build prayer points section
  Widget _buildPrayerPoints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '11. Closing Prayer Points',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _addPrayer,
                icon: const Icon(Icons.add),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prayerControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _prayerControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Prayer focus ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removePrayer(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(left: 8),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
