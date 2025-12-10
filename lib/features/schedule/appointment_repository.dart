import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/appointment.dart';

class AppointmentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new appointment
  Future<Appointment> createAppointment({
    required String title,
    required String eventType,
    required DateTime startTime,
    required DateTime endTime,
    String? location,
    String? notes,
    bool isAllDay = false,
    bool isRecurring = false,
    String? recurrencePattern,
    String? attendees,
    String reminderType = '15min',
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final appointment = Appointment(
        id: id,
        title: title,
        eventType: eventType,
        startTime: startTime,
        endTime: endTime,
        location: location,
        notes: notes,
        isAllDay: isAllDay,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
        attendees: attendees,
        reminderType: reminderType,
        createdAt: now,
        updatedAt: now,
      );

      await _supabase.from('appointments').insert(appointment.toMap());

      return appointment;
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointment(String id) async {
    try {
      final response =
          await _supabase.from('appointments').select().eq('id', id).single();
      return Appointment.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch appointment: $e');
    }
  }

  // Get all appointments
  Future<List<Appointment>> getAllAppointments() async {
    try {
      final response = await _supabase
          .from('appointments')
          .select()
          .order('start_time', ascending: true);
      return (response as List)
          .map((data) => Appointment.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments: $e');
    }
  }

  // Get appointments by date range
  Future<List<Appointment>> getAppointmentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select()
          .gte('start_time', startDate.toIso8601String())
          .lte('end_time', endDate.toIso8601String())
          .order('start_time', ascending: true);
      return (response as List)
          .map((data) => Appointment.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments by date range: $e');
    }
  }

  // Get appointments for a specific day
  Future<List<Appointment>> getAppointmentsByDay(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final response = await _supabase
          .from('appointments')
          .select()
          .gte('start_time', startOfDay.toIso8601String())
          .lte('start_time', endOfDay.toIso8601String())
          .order('start_time', ascending: true);

      return (response as List)
          .map((data) => Appointment.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments for day: $e');
    }
  }

  // Get appointments for a specific week
  Future<List<Appointment>> getAppointmentsByWeek(DateTime date) async {
    try {
      // Get Monday of the week
      final monday = date.subtract(Duration(days: date.weekday - 1));
      final startOfWeek = DateTime(monday.year, monday.month, monday.day);
      // Get Sunday (6 days after Monday)
      final endOfWeek =
          startOfWeek.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));

      return getAppointmentsByDateRange(startOfWeek, endOfWeek);
    } catch (e) {
      throw Exception('Failed to fetch appointments for week: $e');
    }
  }

  // Get appointments for a specific month
  Future<List<Appointment>> getAppointmentsByMonth(int year, int month) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      return getAppointmentsByDateRange(startOfMonth, endOfMonth);
    } catch (e) {
      throw Exception('Failed to fetch appointments for month: $e');
    }
  }

  // Get appointments by event type
  Future<List<Appointment>> getAppointmentsByType(String eventType) async {
    try {
      final response = await _supabase
          .from('appointments')
          .select()
          .eq('event_type', eventType)
          .order('start_time', ascending: true);
      return (response as List)
          .map((data) => Appointment.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch appointments by type: $e');
    }
  }

  // Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments({int limit = 10}) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await _supabase
          .from('appointments')
          .select()
          .gte('start_time', now)
          .order('start_time', ascending: true)
          .limit(limit);
      return (response as List)
          .map((data) => Appointment.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming appointments: $e');
    }
  }

  // Update appointment
  Future<Appointment> updateAppointment(
    String id, {
    String? title,
    String? eventType,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? notes,
    bool? isAllDay,
    bool? isRecurring,
    String? recurrencePattern,
    String? attendees,
    String? reminderType,
    int? notificationId,
  }) async {
    try {
      final existing = await getAppointment(id);
      if (existing == null) {
        throw Exception('Appointment not found');
      }

      final updated = existing.copyWith(
        title: title,
        eventType: eventType,
        startTime: startTime,
        endTime: endTime,
        location: location,
        notes: notes,
        isAllDay: isAllDay,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
        attendees: attendees,
        reminderType: reminderType,
        notificationId: notificationId ?? existing.notificationId,
        updatedAt: DateTime.now(),
      );

      await _supabase.from('appointments').update(updated.toMap()).eq('id', id);

      return updated;
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // Delete appointment
  Future<void> deleteAppointment(String id) async {
    try {
      await _supabase.from('appointments').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  // Search appointments by title or notes
  Future<List<Appointment>> searchAppointments(String query) async {
    try {
      final allAppointments = await getAllAppointments();
      final lowerQuery = query.toLowerCase();

      return allAppointments
          .where((appointment) =>
              appointment.title.toLowerCase().contains(lowerQuery) ||
              (appointment.location?.toLowerCase().contains(lowerQuery) ?? false) ||
              (appointment.notes?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search appointments: $e');
    }
  }

  // Get all event types used
  Future<List<String>> getAllEventTypes() async {
    try {
      final appointments = await getAllAppointments();
      final types = <String>{};
      for (final appointment in appointments) {
        types.add(appointment.eventType);
      }
      return types.toList();
    } catch (e) {
      throw Exception('Failed to fetch event types: $e');
    }
  }
}
