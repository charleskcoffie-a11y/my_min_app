/// Data validation service for all models
class ModelValidator {
  static const minTitleLength = 1;
  static const maxTitleLength = 255;
  static const minDescriptionLength = 0;
  static const maxDescriptionLength = 5000;

  /// Validate task model
  static List<String> validateTask({
    required String title,
    required String category,
    required String priority,
    String description = '',
  }) {
    final errors = <String>[];

    if (title.isEmpty || title.length < minTitleLength) {
      errors.add('Title is required');
    }
    if (title.length > maxTitleLength) {
      errors.add('Title must be less than $maxTitleLength characters');
    }
    if (description.length > maxDescriptionLength) {
      errors.add('Description must be less than $maxDescriptionLength characters');
    }
    if (category.isEmpty) {
      errors.add('Category is required');
    }
    if (priority.isEmpty) {
      errors.add('Priority is required');
    }

    return errors;
  }

  /// Validate appointment model
  static List<String> validateAppointment({
    required String title,
    required DateTime appointmentDate,
    DateTime? reminderAt,
    String description = '',
  }) {
    final errors = <String>[];

    if (title.isEmpty || title.length < minTitleLength) {
      errors.add('Title is required');
    }
    if (title.length > maxTitleLength) {
      errors.add('Title must be less than $maxTitleLength characters');
    }
    if (description.length > maxDescriptionLength) {
      errors.add('Description must be less than $maxDescriptionLength characters');
    }
    if (appointmentDate.isBefore(DateTime.now())) {
      errors.add('Appointment date must be in the future');
    }
    if (reminderAt != null && reminderAt.isAfter(appointmentDate)) {
      errors.add('Reminder cannot be after appointment date');
    }

    return errors;
  }

  /// Validate counseling case model
  static List<String> validateCounselingCase({
    required String personName,
    required String mainIssue,
    String notes = '',
  }) {
    final errors = <String>[];

    if (personName.isEmpty || personName.length < minTitleLength) {
      errors.add('Person name is required');
    }
    if (personName.length > maxTitleLength) {
      errors.add('Person name must be less than $maxTitleLength characters');
    }
    if (mainIssue.isEmpty) {
      errors.add('Main issue is required');
    }
    if (mainIssue.length > maxDescriptionLength) {
      errors.add('Main issue must be less than $maxDescriptionLength characters');
    }
    if (notes.length > maxDescriptionLength) {
      errors.add('Notes must be less than $maxDescriptionLength characters');
    }

    return errors;
  }

  /// Validate standing order model
  static List<String> validateStandingOrder({
    required String title,
    required String content,
    String tags = '',
  }) {
    final errors = <String>[];

    if (title.isEmpty || title.length < minTitleLength) {
      errors.add('Title is required');
    }
    if (title.length > maxTitleLength) {
      errors.add('Title must be less than $maxTitleLength characters');
    }
    if (content.isEmpty) {
      errors.add('Content is required');
    }
    if (content.length > (maxDescriptionLength * 5)) {
      errors.add('Content is too long');
    }
    if (tags.length > maxTitleLength) {
      errors.add('Tags must be less than $maxTitleLength characters');
    }

    return errors;
  }
}
