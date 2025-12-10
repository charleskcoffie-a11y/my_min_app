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

  // New task form state
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Other';
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now();

  // FILTER STATE
  String _statusFilter = 'All';    // All, Pending, Completed
  String _categoryFilter = 'All';  // All, Preaching, Visitation, Counselling, Other

  List<Task> get _filteredTasks {
    return _tasks.where((t) {
      final statusOk = _statusFilter == 'All' || t.status == _statusFilter;
      final categoryOk =
          _categoryFilter == 'All' || t.category == _categoryFilter;
      return statusOk && categoryOk;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _showAddTaskSheet() async {
    _titleController.clear();
    _descriptionController.clear();
    _selectedCategory = 'Other';
    _selectedPriority = 'Medium';
    _selectedDate = DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Preaching',
                            child: Text('Preaching'),
                          ),
                          DropdownMenuItem(
                            value: 'Visitation',
                            child: Text('Visitation'),
                          ),
                          DropdownMenuItem(
                            value: 'Counselling',
                            child: Text('Counselling'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Low',
                            child: Text('Low'),
                          ),
                          DropdownMenuItem(
                            value: 'Medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: 'High',
                            child: Text('High'),
                          ),
                          DropdownMenuItem(
                            value: 'Critical',
                            child: Text('Critical'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPriority = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          'Date: ${_selectedDate.toLocal().toString().split(' ').first}',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Task'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    try {
      await _repo.createTask(
        title: title,
        category: _selectedCategory,
        description: description.isEmpty ? null : description,
        taskDate: _selectedDate,
        priority: _selectedPriority,
      );
      Navigator.of(context).pop(); // close bottom sheet
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving task: $e')),
      );
    }
  }

  Future<void> _toggleCompleted(Task task) async {
    try {
      await _repo.toggleCompleted(task);
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title ?? ''}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _repo.deleteTask(task.id);
      await _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  // ---------- FILTER UI ----------

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _statusFilter,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _statusFilter = value);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _categoryFilter,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Preaching', child: Text('Preaching')),
                DropdownMenuItem(value: 'Visitation', child: Text('Visitation')),
                DropdownMenuItem(
                    value: 'Counselling', child: Text('Counselling')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _categoryFilter = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final visibleTasks = _filteredTasks;

    if (visibleTasks.isEmpty) {
      return const Center(
        child: Text('No tasks match your filters.'),
      );
    }

    return ListView.builder(
      itemCount: visibleTasks.length,
      itemBuilder: (context, index) {
        final t = visibleTasks[index];
        return Dismissible(
          key: ValueKey(t.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            await _deleteTask(t);
            return false; // we reload list manually
          },
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                t.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
              ),
              onPressed: () => _toggleCompleted(t),
            ),
            title: Text(
              t.title ?? 'Untitled task',
              style: TextStyle(
                decoration: t.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(
              '${t.category} • ${t.priority} • ${t.status} • '
              '${t.taskDate.toLocal().toString().split(' ').first}',
            ),
          ),
        );
      },
    );
  }

  // ---------- BUILD ----------

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
        onPressed: _showAddTaskSheet,
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
              : Column(
                  children: [
                    _buildFilters(),          // 👈 filters row
                    const SizedBox(height: 4),
                    Expanded(child: _buildTaskList()),
                  ],
                ),
    );
  }
}
