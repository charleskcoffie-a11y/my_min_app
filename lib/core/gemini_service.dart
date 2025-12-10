import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple service to call Gemini text models.
class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  /// Call the Gemini model with a prompt and get back text.
  Future<String> generateText(String prompt) async {
    // You can change the model name later if needed.
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=$apiKey',
    );

    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final candidates = data["candidates"] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception("No candidates returned by Gemini");
    }

    final text =
        candidates[0]["content"]["parts"][0]["text"] as String? ?? "";
    return text.trim();
  }
}
