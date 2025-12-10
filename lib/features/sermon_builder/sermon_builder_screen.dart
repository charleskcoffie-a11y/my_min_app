import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_min_app/core/gemini_service.dart';
import 'package:my_min_app/models/sermon.dart';
import 'package:my_min_app/features/sermon_builder/sermon_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SermonBuilderScreen extends StatefulWidget {
  final GeminiService gemini;

  const SermonBuilderScreen({super.key, required this.gemini});

  @override
  State<SermonBuilderScreen> createState() => _SermonBuilderScreenState();
}

class _SermonBuilderScreenState extends State<SermonBuilderScreen> {
  final _titleCtrl = TextEditingController();
  final _themeCtrl = TextEditingController();
  final _mainTextCtrl = TextEditingController();
  final _supportingCtrl = TextEditingController();

  final Sermon _current = Sermon(title: '', theme: '', mainText: '');
  final SermonRepository _repo = SermonRepository();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _themeCtrl.dispose();
    _mainTextCtrl.dispose();
    _supportingCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateFromAI() async {
    setState(() => _loading = true);

    final prompt = _buildPrompt();
    try {
      final raw = await widget.gemini.generateText(prompt);

      // Expect JSON from model; attempt to parse
      Map<String, dynamic> data;
      try {
        data = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        // Fallback: wrap raw text into proposition only
        data = {'proposition': raw};
      }

      setState(() {
        // prefer values returned by AI when present
        final aiTitle = data['title'] ?? data['title_text'] ?? data['proposition'];
        final aiTheme = data['theme'];
        final aiMainText = data['main_text'] ?? data['mainText'];

        if (aiTitle != null && (aiTitle as String).isNotEmpty) {
          _titleCtrl.text = aiTitle;
          _current.title = aiTitle;
        } else {
          _current.title = _titleCtrl.text;
        }

        if (aiTheme != null && (aiTheme as String).isNotEmpty) {
          _themeCtrl.text = aiTheme;
          _current.theme = aiTheme;
        } else {
          _current.theme = _themeCtrl.text;
        }

        if (aiMainText != null && (aiMainText as String).isNotEmpty) {
          _mainTextCtrl.text = aiMainText;
          _current.mainText = aiMainText;
        } else {
          _current.mainText = _mainTextCtrl.text;
        }
        // outline and supporting scriptures (accept several key names)
        if (data.containsKey('outline') || data.containsKey('outline_points')) {
          final o = data['outline'] ?? data['outline_points'];
          _current.outline = List<String>.from(o);
        }
        if (data.containsKey('supporting') || data.containsKey('supporting_scriptures') || data.containsKey('supportingScriptures')) {
          final s = data['supporting'] ?? data['supporting_scriptures'] ?? data['supportingScriptures'];
          _current.supportingScriptures = List<String>.from(s);
        }

        if (data.containsKey('applications') || data.containsKey('practical_applications')) {
          final a = data['applications'] ?? data['practical_applications'];
          _current.applications = List<String>.from(a);
        }
        if (data.containsKey('prayerPoints') || data.containsKey('prayer_points')) {
          final p = data['prayerPoints'] ?? data['prayer_points'];
          _current.prayerPoints = List<String>.from(p);
        }

        // proposition / big idea
        if (data.containsKey('proposition') || data.containsKey('proposition') ) {
          _current.proposition = (data['proposition'] ?? '') as String;
        }

        // introduction, background, gospel, conclusion, closing prayer, altar call
        _current.introduction = (data['introduction'] ?? data['introduction_text'] ?? '') as String;
        _current.backgroundContext = (data['backgroundContext'] ?? data['background_context'] ?? '') as String;
        _current.gospelConnection = (data['gospelConnection'] ?? data['gospel_connection'] ?? '') as String;
        _current.conclusion = (data['conclusion'] ?? '') as String;
        _current.closingPrayer = (data['closingPrayer'] ?? data['closing_prayer'] ?? '') as String;
        _current.altarCall = (data['altarCall'] ?? data['altar_call'] ?? '') as String;

        // main points: accept 'main_points' as list of objects
        if (data.containsKey('main_points') || data.containsKey('mainPoints')) {
          final raw = data['main_points'] ?? data['mainPoints'];
          try {
            final list = List<Map<String, dynamic>>.from(raw);
            _current.mainPoints = list.map((m) => m.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))).toList();
          } catch (_) {
            // fallback: if outline exists, map outline items into simple mainPoints
            if (_current.outline.isNotEmpty) {
              _current.mainPoints = _current.outline.map((t) => {'title': t, 'explain': '', 'apply': '', 'call': ''}).toList();
            }
          }
        } else if (_current.outline.isNotEmpty) {
          _current.mainPoints = _current.outline.map((t) => {'title': t, 'explain': '', 'apply': '', 'call': ''}).toList();
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI generation failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  String _buildPrompt() {
    final title = _titleCtrl.text.trim();
    final theme = _themeCtrl.text.trim();
    final main = _mainTextCtrl.text.trim();
    final supporting = _supportingCtrl.text.trim();

    final prompt = '''
  Generate a complete sermon in a pastoral Methodist tone and return ONLY valid JSON matching this template (keys may be camelCase or snake_case):

  - title: string
  - proposition: short, memorable sermon proposition (one sentence)
  - main_text: primary passage reference (e.g., John 8:12)
  - introduction: short paragraph greeting and big idea
  - background_context: short background/context paragraph (who wrote it, audience, historical note)
  - main_points: array of 3 objects, each with { title, explain, apply, call }
  - supporting_scriptures: array of scripture references or short supporting lines
  - practical_applications: array of simple action steps
  - gospel_connection: short paragraph pointing to Christ and grace
  - conclusion: short summary and hopeful closing
  - closing_prayer: short prayer prompt
  - altar_call: optional brief invitation text
  - prayer_points: array of short prayer prompts

  Use the following inputs where available (fill missing fields gracefully):
  Title: $title
  Theme: $theme
  MainText: $main
  Supporting: $supporting

  Ensure main_points has exactly 3 items when possible. Return only valid JSON.
  ''';
    return prompt;
  }

  Future<void> _saveSermon() async {
    try {
      await _repo.saveSermon(_current.toJson());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sermon saved to Supabase.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _saveToFile() async {
    try {
      final jsonStr = jsonEncode(_current.toJson());
      // Save to app documents directory (avoids FilePicker import issues).
      final dir = await getApplicationDocumentsDirectory();
      final safeTitle = _current.title.isNotEmpty ? _current.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_') : 'sermon';
      final filename = '$safeTitle-${DateTime.now().toIso8601String()}.json';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(jsonStr);

      // also write a human-readable text version following the Methodist template
      final text = _formatPlainTextSermon(_current);
      final txtName = filename.replaceFirst('.json', '.txt');
      final txtFile = File('${dir.path}/$txtName');
      await txtFile.writeAsString(text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sermon exported to ${file.path} and ${txtFile.path}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _shareSermon() async {
    try {
      // Share the human-readable sermon text via the platform share sheet (email apps included).
      final text = _formatPlainTextSermon(_current);
      await SharePlus.instance.share(ShareParams(text: text, title: 'Sermon: ${_current.title}'));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sermon shared')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  String _formatPlainTextSermon(Sermon s) {
    final buffer = StringBuffer();
    buffer.writeln('THE METHODIST CHURCH GHANA\nNORTH AMERICA DIOCE\nCANADA CIRCUIT');
    buffer.writeln();
    buffer.writeln('1. Title');
    buffer.writeln(s.title);
    buffer.writeln();
    buffer.writeln('2. Scripture Text');
    buffer.writeln(s.mainText);
    buffer.writeln();
    buffer.writeln('3. Introduction');
    buffer.writeln(s.introduction);
    buffer.writeln();
    buffer.writeln('4. Background / Context');
    buffer.writeln(s.backgroundContext);
    buffer.writeln();
    for (var i = 0; i < s.mainPoints.length; i++) {
      final mp = s.mainPoints[i];
      buffer.writeln('${5 + i}. Main Point ${i + 1} — ${mp['title'] ?? ''}');
      buffer.writeln('Explain: ${mp['explain'] ?? ''}');
      buffer.writeln('Application: ${mp['apply'] ?? ''}');
      buffer.writeln('Call: ${mp['call'] ?? ''}');
      buffer.writeln();
    }
    buffer.writeln('8. Practical Applications');
    for (var a in s.applications) {
      buffer.writeln('- $a');
    }
    buffer.writeln();
    buffer.writeln('9. Gospel Connection');
    buffer.writeln(s.gospelConnection);
    buffer.writeln();
    buffer.writeln('10. Conclusion');
    buffer.writeln(s.conclusion);
    buffer.writeln();
    buffer.writeln('11. Closing Prayer');
    buffer.writeln(s.closingPrayer);
    buffer.writeln();
    buffer.writeln('12. Altar Call / Response Time');
    buffer.writeln(s.altarCall);
    return buffer.toString();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sermon Builder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _themeCtrl, decoration: const InputDecoration(labelText: 'Theme'))),
            ]),
            const SizedBox(height: 8),
            TextField(controller: _mainTextCtrl, decoration: const InputDecoration(labelText: 'Main Bible Text')),
            const SizedBox(height: 8),
            TextField(controller: _supportingCtrl, decoration: const InputDecoration(labelText: 'Supporting Scriptures (comma separated)')),
            const SizedBox(height: 8),

            // Introduction and background
            TextField(controller: TextEditingController(text: _current.introduction),
                decoration: const InputDecoration(labelText: 'Introduction'),
                maxLines: 3,
                onChanged: (v) => _current.introduction = v),
            const SizedBox(height: 8),
            TextField(controller: TextEditingController(text: _current.backgroundContext),
                decoration: const InputDecoration(labelText: 'Background / Context'),
                maxLines: 3,
                onChanged: (v) => _current.backgroundContext = v),

            const SizedBox(height: 8),

            // Ensure there are 3 main points
            Builder(builder: (context) {
              while (_current.mainPoints.length < 3) {
                _current.mainPoints.add({'title': '', 'explain': '', 'apply': '', 'call': ''});
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (i) {
                  final mp = _current.mainPoints[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Main Point ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextField(controller: TextEditingController(text: mp['title']), decoration: const InputDecoration(labelText: 'Title'), onChanged: (v) => mp['title'] = v),
                      TextField(controller: TextEditingController(text: mp['explain']), decoration: const InputDecoration(labelText: 'Explain the text'), maxLines: 2, onChanged: (v) => mp['explain'] = v),
                      TextField(controller: TextEditingController(text: mp['apply']), decoration: const InputDecoration(labelText: 'Application'), maxLines: 2, onChanged: (v) => mp['apply'] = v),
                      TextField(controller: TextEditingController(text: mp['call']), decoration: const InputDecoration(labelText: 'Call to transformation'), maxLines: 1, onChanged: (v) => mp['call'] = v),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              );
            }),

            const SizedBox(height: 8),

            TextField(controller: TextEditingController(text: _current.gospelConnection), decoration: const InputDecoration(labelText: 'Gospel Connection'), maxLines: 3, onChanged: (v) => _current.gospelConnection = v),
            const SizedBox(height: 8),
            TextField(controller: TextEditingController(text: _current.conclusion), decoration: const InputDecoration(labelText: 'Conclusion'), maxLines: 2, onChanged: (v) => _current.conclusion = v),
            const SizedBox(height: 8),
            TextField(controller: TextEditingController(text: _current.closingPrayer), decoration: const InputDecoration(labelText: 'Closing Prayer'), maxLines: 2, onChanged: (v) => _current.closingPrayer = v),
            const SizedBox(height: 8),
            TextField(controller: TextEditingController(text: _current.altarCall), decoration: const InputDecoration(labelText: 'Altar Call / Response (optional)'), maxLines: 2, onChanged: (v) => _current.altarCall = v),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(onPressed: _loading ? null : _generateFromAI, icon: const Icon(Icons.auto_mode), label: const Text('Generate AI Outline')),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: _saveSermon, icon: const Icon(Icons.save), label: const Text('Save')),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: _saveToFile, icon: const Icon(Icons.download), label: const Text('Save to Disk')),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: _shareSermon, icon: const Icon(Icons.email), label: const Text('Email/Share')),
            ]),
            const SizedBox(height: 12),

            const Text('Outline (drag to reorder):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _current.outline.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _current.outline.removeAt(oldIndex);
                  _current.outline.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _current.outline[index];
                return ListTile(
                  key: ValueKey('outline-$index'),
                  title: TextFormField(
                    initialValue: item,
                    onChanged: (v) => _current.outline[index] = v,
                  ),
                  trailing: const Icon(Icons.drag_handle),
                );
              },
            ),

            const SizedBox(height: 12),
            const Text('Supporting Scriptures:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._current.supportingScriptures.map((s) => ListTile(title: Text(s))),

            const SizedBox(height: 12),
            const Text('Applications:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._current.applications.map((a) => ListTile(title: Text(a))),

            const SizedBox(height: 12),
            const Text('Prayer Points:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._current.prayerPoints.map((p) => ListTile(title: Text(p))),
          ],
        ),
      ),
    );
  }
}
