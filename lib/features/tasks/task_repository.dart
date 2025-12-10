import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';
import '../../core/notification_service.dart';

class TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Task>> getAllTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .order('task_date', ascending: true)
        .order('created_at', ascending: true);

    final list = response as List<dynamic>;
    return list
        .map((row) => Task.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> createTask({
    required String title,
    required String category,
    String? description,
    required DateTime taskDate,
    required String priority,
    DateTime? reminderAt,
  }) async {
    final inserted = await _client.from('tasks').insert({
      'title': title,
      'category': category,
      'description': description,
      'task_date': taskDate.toIso8601String(),
      'priority': priority,
      'reminder_at': reminderAt?.toIso8601String(),
      'status': 'Pending',
      'is_completed': false,
    }).select().maybeSingle();

    if (inserted != null && reminderAt != null) {
      try {
        final notifId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
        await NotificationService().schedule(notifId, title, description ?? '', reminderAt);
        await _client.from('tasks').update({'notification_id': notifId}).eq('id', inserted['id']);
      } catch (e) {
        // ignore scheduling errors for now
      }
    }
  }

  Future<void> toggleCompleted(Task task) async {
    final newCompleted = !task.isCompleted;
    await _client.from('tasks').update({
      'is_completed': newCompleted,
      'status': newCompleted ? 'Completed' : 'Pending',
      'completed_at': newCompleted ? DateTime.now().toIso8601String() : null,
    }).eq('id', task.id);

    // if marking completed, cancel scheduled notification
    if (newCompleted && task.notificationId != null) {
      try {
        await NotificationService().cancel(task.notificationId!);
        await _client.from('tasks').update({'notification_id': null}).eq('id', task.id);
      } catch (_) {}
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final row = await _client.from('tasks').select().eq('id', id).maybeSingle();
      if (row != null && row['notification_id'] != null) {
        final nid = row['notification_id'] as int;
        await NotificationService().cancel(nid);
      }
    } catch (_) {}

    await _client.from('tasks').delete().eq('id', id);
  }

  Future<void> updateTask({
    required String id,
    String? title,
    String? category,
    String? description,
    DateTime? taskDate,
    String? priority,
    DateTime? reminderAt,
    String? status,
    bool? isCompleted,
  }) async {
    try {
      final oldRow = await _client.from('tasks').select().eq('id', id).maybeSingle();
      final oldNotifId = oldRow?['notification_id'] as int?;
      final oldReminderAt = oldRow?['reminder_at'] != null ? DateTime.parse(oldRow!['reminder_at'] as String) : null;

      // Cancel old notification if reminder date changed
      if (oldNotifId != null && (reminderAt == null || reminderAt != oldReminderAt)) {
        try {
          await NotificationService().cancel(oldNotifId);
        } catch (_) {}
      }

      // Schedule new notification if reminder is being set or updated
      int? newNotifId;
      if (reminderAt != null && (oldReminderAt == null || reminderAt != oldReminderAt)) {
        newNotifId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
        try {
          await NotificationService().schedule(
            newNotifId,
            title ?? oldRow?['title'] ?? 'Task',
            description ?? oldRow?['description'] ?? '',
            reminderAt,
          );
        } catch (e) {
          newNotifId = null; // Silently fail notification scheduling
        }
      }

      // Update DB
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (category != null) updateData['category'] = category;
      if (description != null) updateData['description'] = description;
      if (taskDate != null) updateData['task_date'] = taskDate.toIso8601String();
      if (priority != null) updateData['priority'] = priority;
      if (reminderAt != null) updateData['reminder_at'] = reminderAt.toIso8601String();
      if (status != null) updateData['status'] = status;
      if (isCompleted != null) {
        updateData['is_completed'] = isCompleted;
        if (isCompleted) updateData['completed_at'] = DateTime.now().toIso8601String();
      }
      if (newNotifId != null) updateData['notification_id'] = newNotifId;
      if (reminderAt == null && oldNotifId != null) updateData['notification_id'] = null;

      if (updateData.isNotEmpty) {
        await _client.from('tasks').update(updateData).eq('id', id);
      }
    } catch (e) {
      rethrow;
    }
  }
}

