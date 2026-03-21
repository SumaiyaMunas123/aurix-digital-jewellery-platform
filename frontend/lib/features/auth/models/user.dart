enum UserRole { customer, jeweller }

class User {
  final String id;
  final String name;
  final String? email;
  final UserRole role;
  final bool verified;
  final String? verificationStatus;

  const User({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    this.verified = false,
    this.verificationStatus,
  });
}