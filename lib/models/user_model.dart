// ============================================================================
// Model: UserModel
// Purpose: Represents an application user for Login and Register functionality.
// Storage: Saved inside Hive 'users_box' as a Map.
// ============================================================================

class UserModel {
  // Unique identifier for the user (can be email or generated ID)
  final String id;

  // The full name of the user
  final String name;

  // The email address used for logging in
  final String email;

  // The password for user authentication
  final String password;

  // Constructor to initialize all required fields
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  // Convert UserModel object to a Map so it can be stored directly into Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  // Create a UserModel object from a Map retrieved from Hive
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
    );
  }
}
