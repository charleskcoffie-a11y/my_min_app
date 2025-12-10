import 'package:flutter/material.dart';
import '../../core/gemini_service.dart';
import '../../models/task.dart';
import 'task_repository.dart';

class TasksScreen extends StatefulWidget {
  final GeminiService gemini;

  const TasksScreen({super.key, required this.gemini});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TaskRepository();
  bool _loading = true;
  String? _error;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _repo.getAllTasks();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addSampleTask() async {
    try {
      await _repo.addSampleTask();
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleTask,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _tasks.isEmpty
                  ? const Center(child: Text('No tasks yet.'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final t = _tasks[index];
                        return ListTile(
                          title: Text(t.title ?? 'Untitled task'),
                          subtitle: Text(
                            '${t.category} • ${t.status} • '
                            '${t.taskDate.toLocal().toString().split(' ').first}',
                          ),
                          trailing: Icon(
                            t.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                          ),
                        );
                      },
                    ),
    );
  }
}
