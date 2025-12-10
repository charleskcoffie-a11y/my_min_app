import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../tasks/task_repository.dart';
import '../../core/error_handler.dart';
import '../../core/model_validator.dart';
import '../../widgets/empty_state_widget.dart';

class PastoralTasksScreen extends StatefulWidget {
  const PastoralTasksScreen({super.key});

  @override
  State<PastoralTasksScreen> createState() => _PastoralTasksScreenState();
}

class _PastoralTasksScreenState extends State<PastoralTasksScreen> {
  final _repo = TaskRepository();
  final _errorHandler = ErrorHandler();
  bool _loading = true;
  List<Task> _tasks = [];
  String? _errorMessage;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _dueDate = DateTime.now();
  DateTime? _reminderAt;
  String _category = 'Preaching';
  String _priority = 'Medium';

  static const List<String> categories = [
    'Preaching',
    'Visitation',
    'Counseling',
    'Administration',
    'Prayer',
    'Bible study',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await _repo.getAllTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _errorMessage = null;
      });
    } catch (e, st) {
      if (!mounted) return;
      final message = _errorHandler.getErrorMessage(e);
      await _errorHandler.logError(e, st, context: 'PastoralTasksScreen._load');
      setState(() => _errorMessage = message);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    await _load();
  }

  Map<String, List<Task>> _groupByCategory() {
    final map = <String, List<Task>>{};
    for (var c in categories) {
      map[c] = [];
    }
    for (var t in _tasks) {
      final cat = categories.contains(t.category) ? t.category : 'Other';
      map[cat]!.add(t);
    }
    // sort each group by due date
    for (var k in map.keys) {
      map[k]!.sort((a, b) => a.taskDate.compareTo(b.taskDate));
    }
    return map;
  }

  Future<void> _showAddTaskSheet() async {
    _titleCtrl.clear();
    _descCtrl.clear();
    _category = categories.first;
    _priority = 'Medium';
    _dueDate = DateTime.now();
    _reminderAt = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Pastoral Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _category = v); },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _pickDueDate, icon: const Icon(Icons.calendar_today), label: Text('Due: ${DateFormat.yMd().format(_dueDate)}'))),
                  const SizedBox(width: 8),
                  Expanded(child: DropdownButtonFormField<String>(initialValue: _priority, items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                  ], onChanged: (v) { if (v != null) setState(() => _priority = v); }, decoration: const InputDecoration(labelText: 'Priority'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Checkbox(value: _reminderAt != null, onChanged: (v) {
                    setState(() { if (v == true) {
                      _reminderAt = DateTime.now().add(const Duration(hours: 1));
                    } else {
                      _reminderAt = null;
                    } });
                  }),
                  const SizedBox(width: 8),
                  const Text('Set reminder'),
                  const Spacer(),
                  if (_reminderAt != null)
                    TextButton(onPressed: _pickReminderDate, child: Text(DateFormat.yMd().add_jm().format(_reminderAt!)))
                ]),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveTask, child: const Text('Save Task'))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(context: context, initialDate: _dueDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (!mounted) return;
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickReminderDate() async {
    final picked = await showDatePicker(context: context, initialDate: _reminderAt ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2100));
    if (!mounted) return;
    if (picked != null) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now().add(const Duration(hours:1))));
      if (!mounted) return;
      if (time != null) {
        setState(() => _reminderAt = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute));
      }
    }
  }

  Future<void> _saveTask() async {
    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();

    final validationErrors = ModelValidator.validateTask(
      title: title,
      category: _category,
      priority: _priority,
      description: description,
    );

    if (validationErrors.isNotEmpty) {
      if (!mounted) return;
      _errorHandler.showError(context, validationErrors.join('\n'));
      return;
    }

    try {
      await _repo.createTask(
        title: title,
        category: _category,
        description: description,
        taskDate: _dueDate,
        priority: _priority,
        reminderAt: _reminderAt,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      _errorHandler.showSuccess(context, 'Task created successfully');
      await _load();
    } catch (e, st) {
      if (!mounted) return;
      await _errorHandler.logError(e, st, context: 'PastoralTasksScreen._saveTask');
      _errorHandler.showError(context, e);
    }
  }

  Future<void> _showTaskDetails(Task t) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.title ?? 'Task'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${t.category}'),
              const SizedBox(height: 6),
              Text('Due: ${DateFormat.yMMMd().format(t.taskDate)}'),
              const SizedBox(height: 6),
              if (t.reminderAt != null)
                Text('Reminder: ${DateFormat.yMMMd().add_jm().format(t.reminderAt!)}'),
              const SizedBox(height: 12),
              Text(t.description ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _repo.deleteTask(t.id);
                if (!mounted) return;
                Navigator.of(context).pop();
                _errorHandler.showSuccess(context, 'Task deleted');
                await _load();
              } catch (e, st) {
                if (!mounted) return;
                await _errorHandler.logError(e, st, context: 'deleteTask');
                _errorHandler.showError(context, e);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByCategory();
    final hasNoTasks = _tasks.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pastoral Task Tracker'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorStateWidget(
                  message: _errorMessage!,
                  onRetry: _refresh,
                )
              : hasNoTasks
                  ? EmptyStateWidget(
                      icon: Icons.task_alt_outlined,
                      title: 'No Tasks Yet',
                      subtitle: 'Create a new pastoral task to get started',
                      actionText: 'Create Task',
                      onAction: _showAddTaskSheet,
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: categories.map((c) {
                          final list = groups[c]!;
                          if (list.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...list.map((t) => Card(
                                child: ListTile(
                                  title: Text(t.title ?? 'Untitled'),
                                  subtitle: Text(
                                    '${DateFormat.yMMMd().format(t.taskDate)} • ${t.priority} • ${t.status}${t.reminderAt != null ? ' • Reminder: ${DateFormat.yMMMd().add_jm().format(t.reminderAt!)}' : ''}',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      t.isCompleted
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                    ),
                                    onPressed: () async {
                                      try {
                                        await _repo.toggleCompleted(t);
                                        await _load();
                                        if (!mounted) return;
                                        _errorHandler.showSuccess(
                                          context,
                                          t.isCompleted
                                              ? 'Task marked complete'
                                              : 'Task marked incomplete',
                                        );
                                      } catch (e, st) {
                                        if (!mounted) return;
                                        await _errorHandler.logError(
                                          e,
                                          st,
                                          context: 'toggleCompleted',
                                        );
                                        _errorHandler.showError(context, e);
                                      }
                                    },
                                  ),
                                  onTap: () => _showTaskDetails(t),
                                ),
                              )),
                              const SizedBox(height: 12),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
    );
  }
}
