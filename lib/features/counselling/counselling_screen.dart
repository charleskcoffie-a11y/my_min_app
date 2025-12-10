import 'package:flutter/material.dart';
import '../../core/gemini_service.dart';
import '../counseling_notes/counseling_notes_screen.dart';

class CounsellingScreen extends StatelessWidget {
  final GeminiService gemini;

  const CounsellingScreen({super.key, required this.gemini});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselling'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counselling & Pastoral Care'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CounselingNotesScreen()),
                );
              },
              icon: const Icon(Icons.note_outlined),
              label: const Text('Open Counseling Notes'),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Use the Counseling Notes tool to securely store and manage confidential pastoral counseling records.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
