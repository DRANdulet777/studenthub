class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String faculty;
  final String group;
  final String avatarUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.faculty,
    required this.group,
    required this.avatarUrl,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? faculty,
    String? group,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      faculty: faculty ?? this.faculty,
      group: group ?? this.group,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'faculty': faculty,
      'group': group,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      faculty: json['faculty'] as String,
      group: json['group'] as String,
      avatarUrl: json['avatarUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
