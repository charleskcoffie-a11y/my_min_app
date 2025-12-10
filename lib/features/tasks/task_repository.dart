//
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/task.dart';

class TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Task>> getAllTasks() async {
    final response = await _client
        .from('tasks')
        .select()
        .order('task_date', ascending: true);

    final list = response as List<dynamic>;
    return list
        .map((row) => Task.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> addSampleTask() async {
    final now = DateTime.now();
    await _client.from('tasks').insert({
      'title': 'Sample task from Flutter',
      'category': 'Other',
      'description': 'Created from the Flutter ministry app',
      'task_date': now.toIso8601String(),
      'priority': 'Medium',
      'status': 'Pending',
      'is_completed': false,
      'created_at': now.toIso8601String(),
    });
  }
}
