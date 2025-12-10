import 'package:flutter/material.dart';
import '../../core/gemini_service.dart';

class DevotionScreen extends StatefulWidget {
  final GeminiService gemini;

  const DevotionScreen({super.key, required this.gemini});

  @override
  State<DevotionScreen> createState() => _DevotionScreenState();
}

class _DevotionScreenState extends State<DevotionScreen> {
  final _themeController = TextEditingController(text: 'Hope in Christ');
  bool _loading = false;
  String? _result;
  String? _error;

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _generateDevotion() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    final theme = _themeController.text.trim();
    final prompt = """
You are an AI assistant helping a Methodist minister in the Ghana Methodist Church.

Generate a daily Christian devotion in this structure:

1. Title
2. Bible text with reference (e.g. John 3:16)
3. Reflection: 150–250 words
4. Short prayer (3–6 sentences)
5. Action point (one practical step)

Requirements:
- Stay within orthodox Christian belief.
- Respect Methodist doctrine and avoid prosperity-gospel emphasis.
- Use clear, simple English that Ghanaian congregations can relate to.

Today's theme: $theme
""";

    try {
      final text = await widget.gemini.generateText(prompt);
      setState(() => _result = text);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Devotion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _themeController,
              decoration: const InputDecoration(
                labelText: 'Theme for today',
                hintText: 'e.g. Faith in Difficult Times',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generateDevotion,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Devotion'),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _result == null
                  ? const Center(
                      child: Text(
                        'Your generated devotion will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        _result!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
