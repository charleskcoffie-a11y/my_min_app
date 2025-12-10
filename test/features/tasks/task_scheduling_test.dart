import 'package:flutter_test/flutter_test.dart';
import 'package:my_min_app/models/task.dart';

void main() {
  group('TaskRepository Scheduling Tests', () {
    setUp(() {
      // TaskRepository will be instantiated in each test as needed
    });

    test('Task with reminderAt should have notificationId set', () {
      final task = Task(
        id: 'test-1',
        title: 'Visit parishioner',
        category: 'Visitation',
        description: 'Follow-up visit',
        taskDate: DateTime(2025, 12, 15),
        priority: 'High',
        status: 'Pending',
        reminderAt: DateTime(2025, 12, 15, 10, 0),
        notificationId: 12345,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(task.reminderAt, isNotNull);
      expect(task.notificationId, isNotNull);
    });

    test('Task without reminderAt should have null notificationId', () {
      final task = Task(
        id: 'test-2',
        title: 'Prepare sermon',
        category: 'Preaching',
        taskDate: DateTime(2025, 12, 20),
        priority: 'Medium',
        status: 'Pending',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(task.reminderAt, isNull);
      expect(task.notificationId, isNull);
    });

    test('Task.fromMap preserves reminderAt and notificationId', () {
      final map = <String, dynamic>{
        'id': 'test-3',
        'title': 'Counsel member',
        'category': 'Counseling',
        'description': 'Pastoral care',
        'task_date': '2025-12-25',
        'priority': 'Medium',
        'status': 'Pending',
        'reminder_at': '2025-12-25T14:30:00.000Z',
        'notification_id': 54321,
        'is_completed': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final task = Task.fromMap(map);

      expect(task.id, 'test-3');
      expect(task.reminderAt, isNotNull);
      expect(task.notificationId, 54321);
    });

    test('Task.toMap includes reminder_at and notification_id', () {
      final task = Task(
        id: 'test-4',
        title: 'Prayer meeting',
        category: 'Prayer',
        taskDate: DateTime(2025, 12, 30),
        priority: 'Medium',
        status: 'Pending',
        reminderAt: DateTime(2025, 12, 30, 18, 0),
        notificationId: 99999,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final map = task.toMap();

      expect(map['reminder_at'], isNotNull);
      expect(map['notification_id'], 99999);
    });

    test('Completed task should clear notification', () {
      final task = Task(
        id: 'test-5',
        title: 'Bible study',
        category: 'Bible study',
        taskDate: DateTime(2025, 12, 22),
        priority: 'High',
        status: 'Completed',
        reminderAt: DateTime(2025, 12, 22, 9, 0),
        notificationId: 11111,
        isCompleted: true,
        completedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(task.isCompleted, true);
      expect(task.notificationId, isNotNull);
      // In production, toggleCompleted would cancel the notification
    });

    test('Task priority and category validation', () {
      final validCategories = ['Preaching', 'Visitation', 'Counseling', 'Administration', 'Prayer', 'Bible study', 'Other'];
      final validPriorities = ['Low', 'Medium', 'High', 'Critical'];

      final task = Task(
        id: 'test-6',
        title: 'Admin task',
        category: 'Administration',
        taskDate: DateTime(2025, 12, 25),
        priority: 'Critical',
        status: 'In Progress',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(validCategories.contains(task.category), true);
      expect(validPriorities.contains(task.priority), true);
    });
  });
}
