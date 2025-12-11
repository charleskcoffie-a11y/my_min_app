import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../devotion/devotion_screen.dart';
import '../counselling/counselling_screen.dart';
import '../counseling_notes/counseling_notes_screen.dart';
import '../programs/program_manager_screen.dart';
import '../pastoral_tasks/pastoral_tasks_screen.dart';
import '../standing_orders/standing_orders_screen.dart';
import '../sermons/sermon_builder_screen.dart';
import '../reminders/reminders_screen.dart';
import '../ideas/ideas_journal_screen.dart';
import '../settings/settings_screen.dart';
import '../sermon_notes/sermon_notes_screen.dart';
import '../../core/gemini_service.dart';

/// More Screen - Contains additional features not in main bottom nav
/// 
/// Features organized in a clean grid:
/// - Devotion
/// - Counselling  
/// - Notes
/// - Programs
/// - Pastoral Tasks
/// - Standing Orders
class MoreScreen extends StatelessWidget {
  final GeminiService geminiService;

  const MoreScreen({super.key, required this.geminiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD),
      appBar: AppBar(
        title: Text(
          'More',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2558),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ministry Tools',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2558),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(
        icon: Icons.menu_book,
        title: 'Devotion',
        subtitle: 'Daily scripture',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DevotionScreen(gemini: geminiService),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.chat_bubble,
        title: 'Counselling',
        subtitle: 'Pastoral care',
        color: const Color(0xFFE91E63),
        bgColor: const Color(0xFFFECDD3),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CounsellingScreen(gemini: geminiService),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.note_outlined,
        title: 'Notes',
        subtitle: 'Counseling notes',
        color: const Color(0xFF009688),
        bgColor: const Color(0xFFB2DFDB),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CounselingNotesScreen(),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.event,
        title: 'Programs',
        subtitle: 'Church programs',
        color: const Color(0xFFFBC02D),
        bgColor: const Color(0xFFFFECB3),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProgramManagerScreen(),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.assignment,
        title: 'Pastoral Tasks',
        subtitle: 'Ministry tasks',
        color: const Color(0xFF6A1B9A),
        bgColor: const Color(0xFFEDE9FE),
        onTap: () => Navigator.pushNamed(context, '/pastoral-tasks'),
      ),
      _FeatureItem(
        icon: Icons.book,
        title: 'Standing Orders',
        subtitle: 'Church guidelines',
        color: const Color(0xFFFDB022),
        bgColor: const Color(0xFFFFF4E5),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StandingOrdersScreen(),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.edit_note,
        title: 'Sermon Builder',
        subtitle: '12-point sermons',
        color: const Color(0xFF1976D2),
        bgColor: const Color(0xFFE3F2FD),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SermonBuilderScreen(),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.notifications_active,
        title: 'Reminders',
        subtitle: 'Ministry reminders',
        color: const Color(0xFFE91E63),
        bgColor: const Color(0xFFFCE4EC),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RemindersScreen(gemini: geminiService),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.lightbulb_outline,
        title: 'Ideas Journal',
        subtitle: 'Capture inspirations',
        color: const Color(0xFFFFC107),
        bgColor: const Color(0xFFFFF8E1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IdeasJournalScreen(gemini: geminiService),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.settings,
        title: 'Settings',
        subtitle: 'Connections & imports',
        color: const Color(0xFF607D8B),
        bgColor: const Color(0xFFECEFF1),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SettingsScreen(),
          ),
        ),
      ),
      _FeatureItem(
        icon: Icons.edit_note,
        title: 'Sermon Notes',
        subtitle: 'Capture insights',
        color: const Color(0xFF5E35B1),
        bgColor: const Color(0xFFEDE7F6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SermonNotesScreen(),
          ),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => _FeatureCard(feature: features[index]),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.feature.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.feature.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.feature.icon,
                    color: widget.feature.color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.feature.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2558),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.feature.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
