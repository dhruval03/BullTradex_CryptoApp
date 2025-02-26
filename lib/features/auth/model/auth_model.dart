// lib/features/auth/models/auth_model.dart
class AuthModel {
  final String email;
  final String password;

  AuthModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
