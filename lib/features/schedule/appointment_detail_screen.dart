import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../core/app_theme.dart';
import '../../core/appointment_notification_service.dart';
import 'appointment_repository.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment? appointment; // null if creating new
  final VoidCallback onSaved;

  const AppointmentDetailScreen({
    super.key,
    this.appointment,
    required this.onSaved,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController notesController;
  late TextEditingController attendeesController;

  String selectedEventType = 'Meeting';
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now().add(const Duration(hours: 1));
  bool isAllDay = false;
  bool isRecurring = false;
  String? recurrencePattern;
  String reminderType = '15min';
  bool isSaving = false;

  final List<String> eventTypes = [
    'Preaching',
    'Meeting',
    'Counseling',
    'Visitation',
    'Study',
    'Off Day'
  ];

  final List<String> reminderOptions = [
    'none',
    '15min',
    '30min',
    '1hour',
    '1day'
  ];

  final List<String> recurrenceOptions = ['weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      final appt = widget.appointment!;
      titleController = TextEditingController(text: appt.title);
      locationController = TextEditingController(text: appt.location ?? '');
      notesController = TextEditingController(text: appt.notes ?? '');
      attendeesController = TextEditingController(text: appt.attendees ?? '');
      selectedEventType = appt.eventType;
      selectedStartTime = appt.startTime;
      selectedEndTime = appt.endTime;
      isAllDay = appt.isAllDay;
      isRecurring = appt.isRecurring;
      recurrencePattern = appt.recurrencePattern;
      reminderType = appt.reminderType;
    } else {
      titleController = TextEditingController();
      locationController = TextEditingController();
      notesController = TextEditingController();
      attendeesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    notesController.dispose();
    attendeesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(
      bool isStart, BuildContext context) async {
    if (!mounted) return;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartTime : selectedEndTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF6D6B63),
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      if (!isAllDay) {
        if (!mounted) return;
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: isStart
              ? TimeOfDay.fromDateTime(selectedStartTime)
              : TimeOfDay.fromDateTime(selectedEndTime),
        );
        if (!mounted) return;
        if (pickedTime != null) {
          final finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (!mounted) return;
          setState(() {
            if (isStart) {
              selectedStartTime = finalDateTime;
              // Ensure end time is after start time
              if (selectedEndTime.isBefore(selectedStartTime)) {
                selectedEndTime =
                    selectedStartTime.add(const Duration(hours: 1));
              }
            } else {
              selectedEndTime = finalDateTime;
              // Ensure end time is after start time
              if (selectedEndTime.isBefore(selectedStartTime)) {
                selectedStartTime =
                    selectedEndTime.subtract(const Duration(hours: 1));
              }
            }
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          if (isStart) {
            selectedStartTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              selectedStartTime.hour,
              selectedStartTime.minute,
            );
          } else {
            selectedEndTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              selectedEndTime.hour,
              selectedEndTime.minute,
            );
          }
        });
      }
    }
  }

  Future<void> _saveAppointment() async {
    if (titleController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final repo = AppointmentRepository();
      final notificationService = AppointmentNotificationService();

      if (widget.appointment != null) {
        // Cancel old notification if exists
        if (widget.appointment!.notificationId != null) {
          await notificationService
              .cancelAppointmentReminder(widget.appointment!.notificationId!);
        }

        // Update existing
        final updated = await repo.updateAppointment(
          widget.appointment!.id,
          title: titleController.text,
          eventType: selectedEventType,
          startTime: selectedStartTime,
          endTime: selectedEndTime,
          location: locationController.text.isNotEmpty ? locationController.text : null,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
          isAllDay: isAllDay,
          isRecurring: isRecurring,
          recurrencePattern: recurrencePattern,
          attendees: attendeesController.text.isNotEmpty ? attendeesController.text : null,
          reminderType: reminderType,
        );

        // Schedule new notification
        if (reminderType != 'none') {
          final notificationId =
              await notificationService.scheduleAppointmentReminder(updated);
          if (notificationId != null) {
            await repo.updateAppointment(
              updated.id,
              notificationId: notificationId,
            );
          }
        }
      } else {
        // Create new
        final created = await repo.createAppointment(
          title: titleController.text,
          eventType: selectedEventType,
          startTime: selectedStartTime,
          endTime: selectedEndTime,
          location: locationController.text.isNotEmpty ? locationController.text : null,
          notes: notesController.text.isNotEmpty ? notesController.text : null,
          isAllDay: isAllDay,
          isRecurring: isRecurring,
          recurrencePattern: recurrencePattern,
          attendees: attendeesController.text.isNotEmpty ? attendeesController.text : null,
          reminderType: reminderType,
        );

        // Schedule notification
        if (reminderType != 'none') {
          final notificationId =
              await notificationService.scheduleAppointmentReminder(created);
          if (notificationId != null) {
            await repo.updateAppointment(
              created.id,
              notificationId: notificationId,
            );
          }
        }
      }

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.appointment != null
                ? 'Appointment updated'
                : 'Appointment created'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment != null
            ? 'Edit Appointment'
            : 'New Appointment'),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Appointment Title',
                hintText: 'e.g., Sunday Sermon, Staff Meeting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            // Event Type
            DropdownButtonFormField<String>(
              initialValue: selectedEventType,
              onChanged: (value) {
                setState(() => selectedEventType = value ?? 'Meeting');
              },
              items: eventTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Event Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),

            // All Day Switch
            Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Day',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: isAllDay,
                      onChanged: (value) {
                        setState(() => isAllDay = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Start Time
            GestureDetector(
              onTap: () => _selectDateTime(true, context),
              child: Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start Date & Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEE, MMM d, yyyy')
                                      .format(selectedStartTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!isAllDay)
                                  Text(
                                    DateFormat('h:mm a')
                                        .format(selectedStartTime),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // End Time
            GestureDetector(
              onTap: () => _selectDateTime(false, context),
              child: Card(
                elevation: 0,
                color: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'End Date & Time',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEE, MMM d, yyyy')
                                      .format(selectedEndTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (!isAllDay)
                                  Text(
                                    DateFormat('h:mm a')
                                        .format(selectedEndTime),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Church Sanctuary, Room 101',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Attendees
            TextField(
              controller: attendeesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Attendees',
                hintText: 'Names or emails (comma-separated)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 16),

            // Reminder Type
            DropdownButtonFormField<String>(
              initialValue: reminderType,
              onChanged: (value) {
                setState(() => reminderType = value ?? '15min');
              },
              items: reminderOptions
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option == 'none' ? 'No Reminder' : option),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Reminder',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notifications),
              ),
            ),
            const SizedBox(height: 16),

            // Recurring Switch
            Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recurring Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: isRecurring,
                      onChanged: (value) {
                        setState(() => isRecurring = value);
                        if (!value) {
                          recurrencePattern = null;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (isRecurring) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: recurrencePattern,
                onChanged: (value) {
                  setState(() => recurrencePattern = value);
                },
                items: recurrenceOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(
                            'Every ${option == 'weekly' ? 'Week' : option == 'monthly' ? 'Month' : 'Year'}',
                          ),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Recurrence Pattern',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Additional details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.appointment != null ? 'Update' : 'Create',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
