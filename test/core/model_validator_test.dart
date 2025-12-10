import 'package:flutter_test/flutter_test.dart';
import 'package:my_min_app/core/model_validator.dart';

void main() {
  group('ModelValidator Tests', () {
    group('validateTask', () {
      test('Valid task passes validation', () {
        final errors = ModelValidator.validateTask(
          title: 'Valid Task',
          category: 'Preaching',
          priority: 'High',
          description: 'A valid task description',
        );
        expect(errors, isEmpty);
      });

      test('Empty title fails validation', () {
        final errors = ModelValidator.validateTask(
          title: '',
          category: 'Preaching',
          priority: 'High',
        );
        expect(errors, contains('Title is required'));
      });

      test('Title exceeding max length fails validation', () {
        final errors = ModelValidator.validateTask(
          title: 'a' * 300,
          category: 'Preaching',
          priority: 'High',
        );
        expect(errors, contains('Title must be less than 255 characters'));
      });

      test('Empty category fails validation', () {
        final errors = ModelValidator.validateTask(
          title: 'Valid Title',
          category: '',
          priority: 'High',
        );
        expect(errors, contains('Category is required'));
      });

      test('Empty priority fails validation', () {
        final errors = ModelValidator.validateTask(
          title: 'Valid Title',
          category: 'Preaching',
          priority: '',
        );
        expect(errors, contains('Priority is required'));
      });
    });

    group('validateAppointment', () {
      test('Valid appointment passes validation', () {
        final errors = ModelValidator.validateAppointment(
          title: 'Meeting',
          appointmentDate: DateTime.now().add(const Duration(days: 1)),
          description: 'A meeting description',
        );
        expect(errors, isEmpty);
      });

      test('Past appointment date fails validation', () {
        final errors = ModelValidator.validateAppointment(
          title: 'Meeting',
          appointmentDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(errors, contains('Appointment date must be in the future'));
      });

      test('Reminder after appointment fails validation', () {
        final appointmentDate = DateTime.now().add(const Duration(days: 1));
        final errors = ModelValidator.validateAppointment(
          title: 'Meeting',
          appointmentDate: appointmentDate,
          reminderAt: appointmentDate.add(const Duration(hours: 1)),
        );
        expect(errors, contains('Reminder cannot be after appointment date'));
      });
    });

    group('validateCounselingCase', () {
      test('Valid case passes validation', () {
        final errors = ModelValidator.validateCounselingCase(
          personName: 'John Doe',
          mainIssue: 'Marriage counseling',
          notes: 'Initial consultation',
        );
        expect(errors, isEmpty);
      });

      test('Empty person name fails validation', () {
        final errors = ModelValidator.validateCounselingCase(
          personName: '',
          mainIssue: 'Issue',
        );
        expect(errors, contains('Person name is required'));
      });

      test('Empty main issue fails validation', () {
        final errors = ModelValidator.validateCounselingCase(
          personName: 'John Doe',
          mainIssue: '',
        );
        expect(errors, contains('Main issue is required'));
      });
    });

    group('validateStandingOrder', () {
      test('Valid standing order passes validation', () {
        final errors = ModelValidator.validateStandingOrder(
          title: 'Standing Order Title',
          content: 'Content of the standing order',
          tags: 'governance,church',
        );
        expect(errors, isEmpty);
      });

      test('Empty title fails validation', () {
        final errors = ModelValidator.validateStandingOrder(
          title: '',
          content: 'Content',
        );
        expect(errors, contains('Title is required'));
      });

      test('Empty content fails validation', () {
        final errors = ModelValidator.validateStandingOrder(
          title: 'Title',
          content: '',
        );
        expect(errors, contains('Content is required'));
      });
    });
  });
}
