import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modern Home Screen with hero header, standing order preview, and quick access grid
class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({super.key});

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern> {
  late Future<Map<String, dynamic>?> standingOrderFuture;

  @override
  void initState() {
    super.initState();
    standingOrderFuture = _fetchStandingOrderOfDay();
  }

  /// Fetch standing order of the day from Supabase
  /// Uses day of month mod total count to select a consistent order
  Future<Map<String, dynamic>?> _fetchStandingOrderOfDay() async {
    try {
      final supabase = Supabase.instance.client;
      final today = DateTime.now();

      // Get all standing orders
      final response = await supabase.from('standing_orders').select('*');

      if (response.isEmpty) return null;

      // Select one based on day of month
      final index = (today.day - 1) % response.length;
      return response[index];
    } catch (e) {
      debugPrint('Error fetching standing order: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FB), // Light lavender background
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Hero Header
            const HeroHeader(),
            const SizedBox(height: 28),

            // Section 2: Standing Order of the Day
            FutureBuilder<Map<String, dynamic>?>(
              future: standingOrderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const StandingOrderOfTheDayCard(
                    title: 'Standing Order of the Day',
                    content: 'Loading...',
                    isLoading: true,
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final order = snapshot.data!;
                  return StandingOrderOfTheDayCard(
                    title: order['title'] ?? 'Standing Order',
                    content: order['content'] ?? 'No content available',
                  );
                } else {
                  return const StandingOrderOfTheDayCard(
                    title: 'Standing Order of the Day',
                    content:
                        'No standing orders available. Create one to get started.',
                    isLoading: false,
                  );
                }
              },
            ),
            const SizedBox(height: 28),

            // Section 3: Quick Access Grid
            const Text(
              'Quick Access',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2A6B),
              ),
            ),
            const SizedBox(height: 12),
            const QuickAccessGrid(),
            const SizedBox(height: 24),

            // Section 4: Pastoral Task Tracker Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Tasks screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navigating to Tasks...')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 24),
                label: const Text(
                  'View Pastoral Tasks',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED), // Purple
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Hero Header Widget
/// Displays greeting, date, and subtitle in a styled card
class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEEE, MMMM d, yyyy');
    final formattedDate = dateFormatter.format(now);
    // final dayName = DateFormat('EEEE').format(now);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C3AED).withValues(alpha: 0.9), // Purple
            const Color(0xFF5B21B6).withValues(alpha: 0.9), // Darker purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: greeting and icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main greeting
                    const Text(
                      'Welcome, Reverend',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      'Your Ministry Dashboard',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Church icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.church,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date and subtitle
          Text(
            'Today — $formattedDate',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Here are your tools for ministry, study, and organization.',
            style: TextStyle(
              fontSize: 17,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standing Order of the Day Card
/// Shows a preview of today's standing order with a "Read More" button
class StandingOrderOfTheDayCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isLoading;

  const StandingOrderOfTheDayCard({
    super.key,
    required this.title,
    required this.content,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Truncate content to 2-3 lines
    final truncatedContent = content.length > 120
        ? '${content.substring(0, 120)}...'
        : content;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFDB022).withValues(alpha: 0.3), // Gold border
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Standing Order of the Day',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2A6B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // Order title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A6B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Content preview
                Text(
                  truncatedContent,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Read More button
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Navigating to Standing Orders...')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDB022), // Gold
                      foregroundColor: const Color(0xFF1F2A6B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Read More',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: icon
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFDB022).withValues(alpha: 0.1), // Light gold
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.menu_book,
                color: const Color(0xFFFDB022),
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Access Grid Widget
/// 2-column grid of quick access cards
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      QuickAccessCardData(
        icon: Icons.book,
        title: 'Devotion',
        subtitle: 'Daily scripture & reflections',
        color: const Color(0xFFEDE9FE), // Light purple
        iconColor: const Color(0xFF7C3AED),
      ),
      QuickAccessCardData(
        icon: Icons.favorite,
        title: 'Counselling',
        subtitle: 'Notes for pastoral care',
        color: const Color(0xFFFECDD3), // Light pink
        iconColor: const Color(0xFFE91E63),
      ),
      QuickAccessCardData(
        icon: Icons.check_circle_outline,
        title: 'Tasks',
        subtitle: 'Track your ministry tasks',
        color: const Color(0xFFC8E6C9), // Light green
        iconColor: const Color(0xFF4CAF50),
      ),
      QuickAccessCardData(
        icon: Icons.calendar_today,
        title: 'Schedule',
        subtitle: 'Programs & events',
        color: const Color(0xFFFFECB3), // Light amber
        iconColor: const Color(0xFFFBC02D),
      ),
      QuickAccessCardData(
        icon: Icons.note_outlined,
        title: 'Notes',
        subtitle: 'Sermon & ministry notes',
        color: const Color(0xFFB2DFDB), // Light teal
        iconColor: const Color(0xFF009688),
      ),
      QuickAccessCardData(
        icon: Icons.music_note,
        title: 'Hymns',
        subtitle: 'MHB, Canticles, CAN',
        color: const Color(0xFFC5CAE9), // Light indigo
        iconColor: const Color(0xFF3F51B5),
      ),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return QuickAccessCard(data: cards[index]);
      },
    );
  }
}

/// Quick Access Card Data Model
class QuickAccessCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;

  QuickAccessCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
  });
}

/// Individual Quick Access Card
/// Animated card with icon, title, and subtitle
class QuickAccessCard extends StatefulWidget {
  final QuickAccessCardData data;

  const QuickAccessCard({super.key, required this.data});

  @override
  State<QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<QuickAccessCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Navigate based on card type
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${widget.data.title}...')),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.04 : 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 12 : 8,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon in colored box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.data.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.iconColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  widget.data.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2A6B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Subtitle
                Text(
                  widget.data.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
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
