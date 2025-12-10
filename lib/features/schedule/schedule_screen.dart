import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../core/app_theme.dart';
import 'appointment_repository.dart';
import 'appointment_detail_screen.dart';
import 'weekly_view_screen.dart';
import 'monthly_view_screen.dart';
import 'agenda_view_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Appointment> _upcomingAppointments;
  bool _isLoading = false;
  final AppointmentRepository _repository = AppointmentRepository();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _upcomingAppointments = [];
    _loadUpcomingAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUpcomingAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _repository.getUpcomingAppointments(limit: 5);
      setState(() => _upcomingAppointments = appointments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openAppointmentDetail(Appointment? appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(
          appointment: appointment,
          onSaved: _loadUpcomingAppointments,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule & Appointments'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_view_week), text: 'Week'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Month'),
            Tab(icon: Icon(Icons.list), text: 'Agenda'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const [
              WeeklyViewScreen(),
              MonthlyViewScreen(),
              AgendaViewScreen(),
            ],
          ),
          // Upcoming Appointments Drawer (shows on demand)
          if (_isLoading || _upcomingAppointments.isNotEmpty)
            Positioned(
              top: 0,
              right: -340,
              child: _buildUpcomingDrawer(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAppointmentDetail(null),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUpcomingDrawer() {
    return Container(
      width: 320,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 16,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_upcomingAppointments.length} appointments',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_upcomingAppointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No upcoming appointments',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _upcomingAppointments.length,
                itemBuilder: (context, index) {
                  final appt = _upcomingAppointments[index];
                  final color = Color(
                    int.parse(
                      '0xFF${appt.eventColor.replaceFirst('#', '')}',
                    ),
                  );

                  return GestureDetector(
                    onTap: () => _openAppointmentDetail(appt),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appt.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        appt.timeDisplay,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('EEE, MMM d').format(appt.startTime),
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
