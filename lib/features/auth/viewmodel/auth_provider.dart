// lib/features/auth/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bulltradex/features/auth/model/auth_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  AuthState({this.isLoading = false, this.isSuccess = false, this.errorMessage});
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> login(AuthModel authModel) async {
    state = AuthState(isLoading: true); // Set loading to true
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(authModel.toJson()),
    );

    if (response.statusCode == 200) {
      state = AuthState(isSuccess: true); // Set success
    } else {
      state = AuthState(errorMessage: 'Login failed! Please try again.'); // Error message
    }
  }
}
