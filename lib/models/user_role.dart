class UserRole {
  final String id;
  final String name; // Admin, Supervisor, Counselor
  final List<String> permissions; // view, create, edit, delete, export, manage_users

  UserRole({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory UserRole.admin() {
    return UserRole(
      id: 'admin',
      name: 'Admin',
      permissions: ['view', 'create', 'edit', 'delete', 'export', 'manage_users', 'view_all_cases'],
    );
  }

  factory UserRole.supervisor() {
    return UserRole(
      id: 'supervisor',
      name: 'Supervisor',
      permissions: ['view', 'create', 'edit', 'delete', 'export', 'view_all_cases'],
    );
  }

  factory UserRole.counselor() {
    return UserRole(
      id: 'counselor',
      name: 'Counselor',
      permissions: ['view', 'create', 'edit', 'export'],
    );
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    final roleString = map['role'] as String? ?? 'counselor';
    final role = roleString == 'admin'
        ? UserRole.admin()
        : roleString == 'supervisor'
            ? UserRole.supervisor()
            : UserRole.counselor();

    return StaffMember(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: role,
      createdAt: DateTime.parse(map['created_at'] as String? ?? DateTime.now().toIso8601String()),
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.id,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}
