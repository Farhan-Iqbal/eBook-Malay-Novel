class User {
  final String userId;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final bool? hasSubscription; // Add this field
  final DateTime? subscriptionExpiry; // Add this field

  User({
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.hasSubscription, // Add to constructor
    this.subscriptionExpiry, // Add to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String,
      hasSubscription: json['has_subscription'] as bool?, // Deserialize
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'] as String)
          : null, // Deserialize
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'has_subscription': hasSubscription, // Serialize
      'subscription_expiry':
          subscriptionExpiry?.toIso8601String(), // Serialize
    };
  }

  // Helper to check if subscription is active
  bool get isSubscriptionActive {
    return hasSubscription == true &&
        subscriptionExpiry != null &&
        subscriptionExpiry!.isAfter(DateTime.now());
  }
}