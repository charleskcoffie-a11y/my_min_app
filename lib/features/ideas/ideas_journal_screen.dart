import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/idea.dart';
import '../../core/gemini_service.dart';

/// Ministry Ideas Journal - Flutter version of the React implementation
class IdeasJournalScreen extends StatefulWidget {
  final GeminiService? gemini;

  const IdeasJournalScreen({super.key, this.gemini});

  @override
  State<IdeasJournalScreen> createState() => _IdeasJournalScreenState();
}

class _IdeasJournalScreenState extends State<IdeasJournalScreen> {
  final _supabase = Supabase.instance.client;

  List<Idea> _ideas = [];
  bool _loading = true;

  bool _isAdding = false;
  String _newDate = DateTime.now().toIso8601String().split('T').first;
  String _newPlace = '';
  String _newNote = '';

  // AI state
  String? _aiExpandedId;
  String _aiContent = '';
  bool _aiLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchIdeas();
  }

  Future<void> _fetchIdeas() async {
    setState(() => _loading = true);
    try {
      final response = await _supabase
          .from('ideas')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _ideas = (response as List)
            .map((e) => Idea.fromMap(e as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ideas: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveIdea() async {
    if (_newNote.trim().isEmpty || _newDate.isEmpty) return;
    try {
      await _supabase.from('ideas').insert({
        'idea_date': _newDate,
        'place': _newPlace.isEmpty ? null : _newPlace,
        'note': _newNote.trim(),
      });
      _newDate = DateTime.now().toIso8601String().split('T').first;
      _newPlace = '';
      _newNote = '';
      setState(() => _isAdding = false);
      await _fetchIdeas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving idea: $e')),
      );
    }
  }

  Future<void> _expandIdeaWithAi(Idea idea) async {
    if (widget.gemini == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI service not available')),
      );
      return;
    }

    if (_aiExpandedId == idea.id) {
      setState(() {
        _aiExpandedId = null;
        _aiContent = '';
      });
      return;
    }

    setState(() {
      _aiExpandedId = idea.id;
      _aiLoading = true;
      _aiContent = '';
    });

    try {
      final prompt = 'Expand this ministry idea with next steps, scriptures, and potential impact: ${idea.note}';
      final result = await widget.gemini!.generateText(prompt);
      setState(() => _aiContent = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI error: $e')),
      );
    } finally {
      setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          'Ministry Ideas Journal',
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
              if (_isAdding) _buildNewIdeaCard(),
              const SizedBox(height: 12),
              _loading ? _buildLoading() : _buildIdeasGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ministry Ideas Journal',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2558),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Capture thoughts, inspirations, and locations',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => setState(() => _isAdding = !_isAdding),
          icon: Icon(_isAdding ? Icons.close : Icons.add),
          label: Text(_isAdding ? 'Close' : 'New Idea'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A1B9A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildNewIdeaCard() {
    return Card(
      color: const Color(0xFFFFF8E1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Capture a thought',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _newDate),
                    readOnly: true,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.tryParse(_newDate) ?? DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _newDate = picked.toIso8601String().split('T').first;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Location / Context',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _newPlace = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'The Idea',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 4,
              onChanged: (v) => _newNote = v,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saveIdea,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save to Journal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildIdeasGrid() {
    if (_ideas.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No ideas yet. Capture your first thought!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 12,
        mainAxisExtent: 240,
      ),
      itemCount: _ideas.length,
      itemBuilder: (context, index) {
        return _buildIdeaCard(_ideas[index]);
      },
    );
  }

  Widget _buildIdeaCard(Idea idea) {
    final dateText = DateFormat('yMMMd').format(idea.ideaDate);

    return Card(
      elevation: 1,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dateText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (idea.place != null && idea.place!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.place, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            idea.place!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  idea.note,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_aiExpandedId == idea.id)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: _aiLoading
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Generative thinking...',
                            style: GoogleFonts.poppins(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : _aiContent.isEmpty
                        ? Text(
                            'No AI suggestions yet.',
                            style: GoogleFonts.poppins(
                              color: Colors.purple.shade700,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Suggestions',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _aiContent,
                                style: GoogleFonts.poppins(
                                  color: Colors.purple.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _expandIdeaWithAi(idea),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(_aiExpandedId == idea.id ? 'Close AI' : 'Expand with AI'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
