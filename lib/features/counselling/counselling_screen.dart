import 'package:flutter/material.dart';
import '../../core/gemini_service.dart';

class CounsellingScreen extends StatelessWidget {
  final GeminiService gemini;

  const CounsellingScreen({super.key, required this.gemini});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselling'),
      ),
      body: const Center(
        child: Text('Counselling feature coming soon.'),
      ),
    );
  }
}
