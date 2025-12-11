import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/sermon_note.dart';

/// Sermon/Talk Notes - Comprehensive note-taking for sermons
class SermonNotesScreen extends StatefulWidget {
  const SermonNotesScreen({super.key});

  @override
  State<SermonNotesScreen> createState() => _SermonNotesScreenState();
}

class _SermonNotesScreenState extends State<SermonNotesScreen> {
  final _supabase = Supabase.instance.client;

  String _mode = 'list'; // 'list' or 'edit'
  bool _loading = false;
  bool _saving = false;
  List<SermonNote> _notes = [];

  late SermonNote _currentNote;
  final Map<int, bool> _openSections = {
    1: true,
    2: false,
    3: true,
    4: false,
    5: false,
    6: false,
    7: false,
    8: false,
    9: false,
  };

  @override
  void initState() {
    super.initState();
    _resetNote();
    _fetchNotes();
  }

  void _resetNote() {
    _currentNote = SermonNote(
      preacher: '',
      noteDate: DateTime.now(),
      location: '',
      sermonTitle: '',
      mainScripture: '',
      openingRemarks: '',
      passageContext: '',
      keyThemes: '',
      keyDoctrines: '',
      theologicalStrengths: '',
      theologicalQuestions: '',
      toneAtmosphere: '',
      useOfScripture: '',
      useOfStories: '',
      audienceEngagement: '',
      flowTransitions: '',
      memorablePhrases: '',
      ministerLessons: '',
      personalChallenge: '',
      applicationToPreaching: '',
      pastoralInsights: '',
      callsToAction: '',
      spiritualChallenges: '',
      practicalApplications: '',
      prayerPoints: '',
      closingScripture: '',
      centralMessageSummary: '',
      finalMemorableLine: '',
      followupScriptures: '',
      followupTopics: '',
      followupPeople: '',
      followupMinistryIdeas: '',
      points: [
        SermonPoint(pointNumber: 1, mainPoint: '', supportingScripture: '', keyQuotes: '', illustrations: '', ministryEmphasis: ''),
        SermonPoint(pointNumber: 2, mainPoint: '', supportingScripture: '', keyQuotes: '', illustrations: '', ministryEmphasis: ''),
        SermonPoint(pointNumber: 3, mainPoint: '', supportingScripture: '', keyQuotes: '', illustrations: '', ministryEmphasis: ''),
      ],
    );
  }

  Future<void> _fetchNotes() async {
    setState(() => _loading = true);
    try {
      final response = await _supabase
          .from('sermon_talk_notes')
          .select()
          .order('note_date', ascending: false);
      setState(() {
        _notes = (response as List).map((e) => SermonNote.fromMap(e)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchNoteDetails(String id) async {
    setState(() => _loading = true);
    try {
      final noteData = await _supabase.from('sermon_talk_notes').select().eq('id', id).single();
      final pointsData = await _supabase.from('sermon_talk_points').select().eq('note_id', id).order('point_number');

      setState(() {
        _currentNote = SermonNote.fromMap(noteData).copyWith(
          points: (pointsData as List).map((e) => SermonPoint.fromMap(e)).toList(),
        );
        _mode = 'edit';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveNote() async {
    if (_currentNote.sermonTitle.isEmpty && _currentNote.preacher.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter at least title or preacher')));
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await _supabase.from('sermon_talk_notes').upsert(_currentNote.toMap()).select().single();
      final noteId = response['id'] as String;

      await _supabase.from('sermon_talk_points').delete().eq('note_id', noteId);
      if (_currentNote.points.isNotEmpty) {
        final pointsData = _currentNote.points.asMap().entries.map((e) {
          return SermonPoint(
            pointNumber: e.key + 1,
            mainPoint: e.value.mainPoint,
            supportingScripture: e.value.supportingScripture,
            keyQuotes: e.value.keyQuotes,
            illustrations: e.value.illustrations,
            ministryEmphasis: e.value.ministryEmphasis,
          ).toMap(noteId);
        }).toList();
        await _supabase.from('sermon_talk_points').insert(pointsData);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!')));
      setState(() => _mode = 'list');
      await _fetchNotes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await _supabase.from('sermon_talk_notes').delete().eq('id', id);
      await _fetchNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _mode == 'list' ? _buildListView() : _buildEditorView(),
    );
  }

  Widget _buildListView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text('Sermon Notes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.indigo,
          floating: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _resetNote();
                setState(() => _mode = 'edit');
              },
            ),
          ],
        ),
        if (_loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (_notes.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No sermon notes yet', style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = _notes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(note.sermonTitle.isEmpty ? 'Untitled' : note.sermonTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${note.preacher} • ${DateFormat.yMMMd().format(note.noteDate)}'),
                          if (note.location.isNotEmpty) Text(note.location, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(note.id!),
                      ),
                      onTap: () => _fetchNoteDetails(note.id!),
                    ),
                  );
                },
                childCount: _notes.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditorView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(_currentNote.id == null ? 'New Note' : 'Edit Note'),
          backgroundColor: Colors.indigo,
          floating: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _mode = 'list'),
          ),
          actions: [
            IconButton(
              icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
              onPressed: _saving ? null : _saveNote,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSection(1, 'Basic Information', _buildBasicInfo()),
              _buildSection(2, 'Opening & Context', _buildOpeningContext()),
              _buildSection(3, 'Sermon Structure', _buildSermonStructure()),
              _buildSection(4, 'Theological Highlights', _buildTheological()),
              _buildSection(5, 'Preaching Style', _buildPreachingStyle()),
              _buildSection(6, 'Personal Reflections', _buildPersonalReflections()),
              _buildSection(7, 'Application', _buildApplication()),
              _buildSection(8, 'Closing', _buildClosing()),
              _buildSection(9, 'Follow-Up', _buildFollowUp()),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(int num, String title, Widget content) {
    final isOpen = _openSections[num] ?? false;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _openSections[num] = !isOpen),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$num. $title', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Icon(isOpen ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (isOpen) content,
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Preacher'),
            controller: TextEditingController(text: _currentNote.preacher)..selection = TextSelection.fromPosition(TextPosition(offset: _currentNote.preacher.length)),
            onChanged: (v) => _currentNote = SermonNote(
              id: _currentNote.id,
              preacher: v,
              noteDate: _currentNote.noteDate,
              location: _currentNote.location,
              sermonTitle: _currentNote.sermonTitle,
              mainScripture: _currentNote.mainScripture,
              openingRemarks: _currentNote.openingRemarks,
              passageContext: _currentNote.passageContext,
              keyThemes: _currentNote.keyThemes,
              keyDoctrines: _currentNote.keyDoctrines,
              theologicalStrengths: _currentNote.theologicalStrengths,
              theologicalQuestions: _currentNote.theologicalQuestions,
              toneAtmosphere: _currentNote.toneAtmosphere,
              useOfScripture: _currentNote.useOfScripture,
              useOfStories: _currentNote.useOfStories,
              audienceEngagement: _currentNote.audienceEngagement,
              flowTransitions: _currentNote.flowTransitions,
              memorablePhrases: _currentNote.memorablePhrases,
              ministerLessons: _currentNote.ministerLessons,
              personalChallenge: _currentNote.personalChallenge,
              applicationToPreaching: _currentNote.applicationToPreaching,
              pastoralInsights: _currentNote.pastoralInsights,
              callsToAction: _currentNote.callsToAction,
              spiritualChallenges: _currentNote.spiritualChallenges,
              practicalApplications: _currentNote.practicalApplications,
              prayerPoints: _currentNote.prayerPoints,
              closingScripture: _currentNote.closingScripture,
              centralMessageSummary: _currentNote.centralMessageSummary,
              finalMemorableLine: _currentNote.finalMemorableLine,
              followupScriptures: _currentNote.followupScriptures,
              followupTopics: _currentNote.followupTopics,
              followupPeople: _currentNote.followupPeople,
              followupMinistryIdeas: _currentNote.followupMinistryIdeas,
              points: _currentNote.points,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: 'Sermon Title'),
            controller: TextEditingController(text: _currentNote.sermonTitle)..selection = TextSelection.fromPosition(TextPosition(offset: _currentNote.sermonTitle.length)),
            onChanged: (v) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(context: context, initialDate: _currentNote.noteDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (date != null) setState(() {});
            },
            child: Text('Date: ${DateFormat.yMMMd().format(_currentNote.noteDate)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningContext() => const Padding(padding: EdgeInsets.all(16), child: Text('Opening fields here'));
  Widget _buildSermonStructure() => const Padding(padding: EdgeInsets.all(16), child: Text('Points editor here'));
  Widget _buildTheological() => const Padding(padding: EdgeInsets.all(16), child: Text('Theological fields'));
  Widget _buildPreachingStyle() => const Padding(padding: EdgeInsets.all(16), child: Text('Style fields'));
  Widget _buildPersonalReflections() => const Padding(padding: EdgeInsets.all(16), child: Text('Reflections'));
  Widget _buildApplication() => const Padding(padding: EdgeInsets.all(16), child: Text('Application'));
  Widget _buildClosing() => const Padding(padding: EdgeInsets.all(16), child: Text('Closing'));
  Widget _buildFollowUp() => const Padding(padding: EdgeInsets.all(16), child: Text('Follow-up'));
}
