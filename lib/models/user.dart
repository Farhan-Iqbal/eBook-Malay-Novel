class User {
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
    };
  }
}