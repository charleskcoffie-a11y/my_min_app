import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';

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
  }) async {
    await _client.from('tasks').insert({
      'title': title,
      'category': category,
      'description': description,
      'task_date': taskDate.toIso8601String(),
      'priority': priority,
      'status': 'Pending',
      'is_completed': false,
    });
  }

  Future<void> toggleCompleted(Task task) async {
    final newCompleted = !task.isCompleted;
    await _client
        .from('tasks')
        .update({
          'is_completed': newCompleted,
          'status': newCompleted ? 'Completed' : 'Pending',
          'completed_at': newCompleted ? DateTime.now().toIso8601String() : null,
        })
        .eq('id', task.id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }
}

