import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../core/app_theme.dart';
import 'appointment_repository.dart';
import 'appointment_detail_screen.dart';

class WeeklyViewScreen extends StatefulWidget {
  const WeeklyViewScreen({super.key});

  @override
  State<WeeklyViewScreen> createState() => _WeeklyViewScreenState();
}

class _WeeklyViewScreenState extends State<WeeklyViewScreen> {
  late DateTime _currentWeekStart;
  List<Appointment> _weekAppointments = [];
  bool _isLoading = false;
  final AppointmentRepository _repository = AppointmentRepository();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getMonday(DateTime.now());
    _loadWeekAppointments();
  }

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> _loadWeekAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _repository.getAppointmentsByWeek(_currentWeekStart);
      setState(() => _weekAppointments = appointments);
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

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    _loadWeekAppointments();
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    _loadWeekAppointments();
  }

  void _goToToday() {
    setState(() {
      _currentWeekStart = _getMonday(DateTime.now());
    });
    _loadWeekAppointments();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _weekAppointments.where((appt) {
      return appt.startTime.year == day.year &&
          appt.startTime.month == day.month &&
          appt.startTime.day == day.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  void _openAppointmentDetail(Appointment? appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(
          appointment: appointment,
          onSaved: _loadWeekAppointments,
        ),
      ),
    );
  }

  Future<void> _deleteAppointment(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteAppointment(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment deleted')),
          );
          _loadWeekAppointments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekEnd = _currentWeekStart.add(const Duration(days: 6));
    final weekLabel =
        '${DateFormat('MMM d').format(_currentWeekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly View'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Week Navigation
          Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousWeek,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          weekLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Week ${DateFormat('ww').format(_currentWeekStart)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWeek,
                  ),
                ],
              ),
            ),
          ),

          // Today Button
          if (_currentWeekStart.compareTo(_getMonday(DateTime.now())) != 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _goToToday,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Go to Today'),
                ),
              ),
            ),

          // Week Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: List.generate(7, (index) {
                        final day = _currentWeekStart.add(Duration(days: index));
                        final dayAppointments = _getAppointmentsForDay(day);
                        final isToday = day.year == DateTime.now().year &&
                            day.month == DateTime.now().month &&
                            day.day == DateTime.now().day;

                        return _buildDayColumn(day, dayAppointments, isToday);
                      }),
                    ),
                  ),
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

  Widget _buildDayColumn(
      DateTime day, List<Appointment> appointments, bool isToday) {
    final dayName = DateFormat('EEE').format(day);
    final dayNumber = day.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isToday
              ? AppTheme.lightTheme.primaryColor
              : Colors.grey[300]!,
          width: isToday ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isToday ? Colors.blue[50] : Colors.white,
      ),
      child: Column(
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isToday
                  ? AppTheme.lightTheme.primaryColor
                  : Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Column(
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  dayNumber.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Appointments
          if (appointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No appointments',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...appointments.map((appt) => _buildAppointmentTile(appt)),

          // Add Button
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  final newAppt = Appointment(
                    id: '',
                    title: '',
                    eventType: 'Meeting',
                    startTime: DateTime(day.year, day.month, day.day, 10, 0),
                    endTime: DateTime(day.year, day.month, day.day, 11, 0),
                    createdAt: DateTime.now(),
                  );
                  _openAppointmentDetail(newAppt);
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(Appointment appointment) {
    final color = Color(int.parse('0xFF${appointment.eventColor.replaceFirst('#', '')}'));

    return GestureDetector(
      onTap: () => _openAppointmentDetail(appointment),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _openAppointmentDetail(appointment),
                      child: const Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () => _deleteAppointment(appointment.id),
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appointment.timeDisplay,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
            if (appointment.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.location!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
