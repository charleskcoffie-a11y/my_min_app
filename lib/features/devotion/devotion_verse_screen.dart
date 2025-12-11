import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/daily_verse.dart';
import '../../repositories/daily_verse_repository.dart';
import '../../services/devotional_ai_service.dart';
import '../../core/gemini_service.dart';

/// Screen displaying today's Verse of the Day with AI-generated devotional content
/// 
/// Design:
/// - Full-screen background image from verse.imageUrl
/// - Bottom white panel with verse reference and text
/// - AI-generated devotion, prayer, and action points
/// - Clean, calm aesthetic matching app theme
class DevotionVerseScreen extends StatefulWidget {
  final String? verseId; // Optional: specific verse to load
  final GeminiService gemini;

  const DevotionVerseScreen({
    super.key,
    this.verseId,
    required this.gemini,
  });

  @override
  State<DevotionVerseScreen> createState() => _DevotionVerseScreenState();
}

class _DevotionVerseScreenState extends State<DevotionVerseScreen> {
  final _repository = DailyVerseRepository();
  late final DevotionalAIService _aiService;
  
  DailyVerse? _verse;
  DevotionalContent? _devotionalContent;
  bool _isLoading = true;
  bool _isGeneratingContent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _aiService = DevotionalAIService(widget.gemini);
    _loadVerse();
  }

  /// Load the verse and generate AI content
  Future<void> _loadVerse() async {
    setState(() => _isLoading = true);
    
    try {
      DailyVerse? verse;

      if (widget.verseId != null) {
        // Load specific verse by ID
        verse = await _repository.getVerseById(widget.verseId!);
      } else {
        // Load verse for today (using rotation)
        verse = await _repository.getVerseForToday();
      }

      if (verse != null) {
        setState(() {
          _verse = verse;
          _error = null;
          _isLoading = false;
          _isGeneratingContent = true;
        });

        // Generate AI devotional content
        try {
          final content = await _aiService.generateComplete(verse);
          setState(() {
            _devotionalContent = content;
            _isGeneratingContent = false;
          });
        } catch (e) {
          print('Error generating devotional content: $e');
          setState(() => _isGeneratingContent = false);
        }
      } else {
        setState(() {
          _error = 'No verse available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading verse: $e';
        _isLoading = false;
      });
    }
  }

  /// Share the verse via WhatsApp, email, or other apps
  Future<void> _shareVerse() async {
    if (_verse == null) return;

    final shareText = '''
${_verse!.fullReference}

${_verse!.text}

— Rev Charles K. Coffie
''';

    await Share.share(
      shareText,
      subject: 'Verse of the Day: ${_verse!.fullReference}',
    );
  }

  /// Build a section title with icon
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF6A1B9A),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2558),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F7FD),
        appBar: AppBar(
          title: Text(
            'Verse of the Day',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _verse == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F7FD),
        appBar: AppBar(
          title: Text(
            'Verse of the Day',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF6A1B9A),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'No verse available',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadVerse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text(
          'Verse of the Day',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _shareVerse,
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Verse',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          if (_verse!.imageUrl != null && _verse!.imageUrl!.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                _verse!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.image, size: 80),
              ),
            ),

          // Gradient overlay at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),

          // Content - Scrollable devotional content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Spacer for image
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                  // Verse card
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reference and translation
                            Text(
                              _verse!.fullReference,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2558),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Verse text
                            Text(
                              _verse!.text,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                height: 1.6,
                                color: const Color(0xFF64748B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            if (_verse!.date != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                DateFormat('MMMM d, yyyy').format(_verse!.date!),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                            
                            // AI-Generated Content Section
                            if (_isGeneratingContent) ...[
                              const SizedBox(height: 24),
                              const Center(
                                child: CircularProgressIndicator(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Generating devotional...',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else if (_devotionalContent != null) ...[
                              const SizedBox(height: 24),
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              
                              // Devotion Section
                              _buildSectionTitle('Today\'s Devotion', Icons.auto_stories),
                              const SizedBox(height: 8),
                              Text(
                                _devotionalContent!.devotion,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  height: 1.6,
                                  color: const Color(0xFF1F2558),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Prayer Section
                              _buildSectionTitle('Prayer', Icons.favorite),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6A1B9A).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF6A1B9A).withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  _devotionalContent!.prayer,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: const Color(0xFF1F2558),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Action Points Section
                              _buildSectionTitle('Today\'s Actions', Icons.check_circle_outline),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  _devotionalContent!.actionPoints,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: const Color(0xFF1F2558),
                                  ),
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Rev Charles K. Coffie',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6A1B9A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
