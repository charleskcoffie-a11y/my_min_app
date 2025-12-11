import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modern, stylish Home Screen with refined UI components
/// 
/// Features:
/// - Poppins/Nunito font for modern typography
/// - Compact, refined Quick Access grid (2 columns, 6 cards)
/// - Polished "View Pastoral Tasks" button
/// - Responsive layout for all device sizes
class HomeScreenRedesigned extends StatefulWidget {
  const HomeScreenRedesigned({super.key});

  @override
  State<HomeScreenRedesigned> createState() => _HomeScreenRedesignedState();
}

class _HomeScreenRedesignedState extends State<HomeScreenRedesigned> {
  late Future<Map<String, dynamic>?> standingOrderFuture;

  @override
  void initState() {
    super.initState();
    standingOrderFuture = _fetchStandingOrderOfDay();
  }

  /// Fetch standing order of the day from Supabase
  Future<Map<String, dynamic>?> _fetchStandingOrderOfDay() async {
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now();
      final response = await supabase.from('standing_orders').select('*');
      if (response.isEmpty) return null;
      final index = (today.day - 1) % response.length;
      return response[index] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching standing order: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FD), // Light off-white/lavender
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Header - Welcome section
              _buildHeroHeader(),
              const SizedBox(height: 24),

              // Standing Order of the Day
              FutureBuilder<Map<String, dynamic>?>(
                future: standingOrderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const StandingOrderCard(
                      title: 'Standing Order of the Day',
                      content: 'Loading...',
                      isLoading: true,
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final order = snapshot.data!;
                    return StandingOrderCard(
                      title: order['title'] ?? 'Standing Order',
                      content: order['content'] ?? 'No content available',
                    );
                  } else {
                    return const StandingOrderCard(
                      title: 'Standing Order of the Day',
                      content: 'No standing orders available.',
                      isLoading: false,
                    );
                  }
                },
              ),
              const SizedBox(height: 28),

              // Quick Access Section Title
              Text(
                'Quick Access',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2558), // Deep navy
                ),
              ),
              const SizedBox(height: 16),

              // Quick Access Grid - 6 compact cards in 2 columns
              const QuickAccessGrid(),
              const SizedBox(height: 28),

              // View Pastoral Tasks Button - Polished CTA
              const PastoralTasksButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Hero Header Widget - Welcome message with date
  Widget _buildHeroHeader() {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ministry Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.church,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standing Order Card - Clean preview with "Read More" button
class StandingOrderCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isLoading;

  const StandingOrderCard({
    super.key,
    required this.title,
    required this.content,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final truncatedContent = content.length > 100
        ? '${content.substring(0, 100)}...'
        : content;

    return Container(
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
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Standing Order of the Day',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2558),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  truncatedContent,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigating to Standing Orders...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDB022),
                      foregroundColor: const Color(0xFF1F2558),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      'Read More',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 70,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFFDB022).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.menu_book,
                color: Color(0xFFFDB022),
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Access Grid - 2 columns, 6 refined cards
/// 
/// CUSTOMIZATION:
/// - Change card colors in QuickAccessCard widgets below
/// - Adjust card size by changing childAspectRatio (higher = shorter cards)
/// - Modify spacing with crossAxisSpacing and mainAxisSpacing
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Define all Quick Access cards
    final cards = [
      const QuickAccessCard(
        icon: Icons.book,
        title: 'Devotion',
        subtitle: 'Daily scripture',
        backgroundColor: Color(0xFFEDE9FE), // Light purple
        iconColor: Color(0xFF7C3AED),
      ),
      const QuickAccessCard(
        icon: Icons.favorite,
        title: 'Counselling',
        subtitle: 'Pastoral care',
        backgroundColor: Color(0xFFFECDD3), // Light pink
        iconColor: Color(0xFFE91E63),
      ),
      const QuickAccessCard(
        icon: Icons.check_circle_outline,
        title: 'Tasks',
        subtitle: 'Ministry tasks',
        backgroundColor: Color(0xFFC8E6C9), // Light green
        iconColor: Color(0xFF4CAF50),
      ),
      const QuickAccessCard(
        icon: Icons.calendar_today,
        title: 'Schedule',
        subtitle: 'Programs & events',
        backgroundColor: Color(0xFFFFECB3), // Light amber
        iconColor: Color(0xFFFBC02D),
      ),
      const QuickAccessCard(
        icon: Icons.note_outlined,
        title: 'Notes',
        subtitle: 'Sermon notes',
        backgroundColor: Color(0xFFB2DFDB), // Light teal
        iconColor: Color(0xFF009688),
      ),
      const QuickAccessCard(
        icon: Icons.music_note,
        title: 'Hymns',
        subtitle: 'MHB & Canticles',
        backgroundColor: Color(0xFFC5CAE9), // Light indigo
        iconColor: Color(0xFF3F51B5),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        childAspectRatio: 1.15, // Makes cards compact but not cramped
        crossAxisSpacing: 14, // Space between columns
        mainAxisSpacing: 14, // Space between rows
      ),
      itemCount: cards.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

/// Individual Quick Access Card - Refined and compact
/// 
/// CUSTOMIZATION:
/// - backgroundColor: Background color of the card
/// - iconColor: Color of the icon
/// - Adjust padding in Container for tighter/looser fit
/// - Change borderRadius for sharper/rounder corners
class QuickAccessCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconColor;

  const QuickAccessCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  State<QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<QuickAccessCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening ${widget.title}...')),
        );
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // Reduced padding for compact look
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon in colored rounded square
                Container(
                  width: 48, // Smaller icon container
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 26, // Smaller icon size
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title - Bold and prominent
                Text(
                  widget.title,
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
                // Subtitle - Muted grey
                Text(
                  widget.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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

/// Pastoral Tasks Button - Polished primary CTA
/// 
/// CUSTOMIZATION:
/// - Change gradient colors below
/// - Adjust borderRadius for pill shape
/// - Modify height in SizedBox
/// - Update shadow color/blur for glow effect
class PastoralTasksButton extends StatelessWidget {
  const PastoralTasksButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Good vertical padding
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/pastoral-tasks');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A1B9A), // Purple
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: const Color(0xFF6A1B9A).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // Pill shape
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 22),
            const SizedBox(width: 10),
            Text(
              'View Pastoral Tasks',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
