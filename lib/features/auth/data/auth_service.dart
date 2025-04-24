import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://192.168.49.134:5000/api/auth";

  Future<String?> login(String email, String password) async {
    try {
      // Reset any inconsistent state
      await resetAuthState();

      // Normalize email to lowercase
      final normalizedEmail = email.trim().toLowerCase();

      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": normalizedEmail,
          "password": password,
        }),
      );

      print("🔄 Server response: ${response.statusCode} - ${response.body}");
      
      // Attempt to parse response even if status code is not 200
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print("❌ Could not parse response: $e");
        return "Server response format error";
      }
      
      if (response.statusCode == 200) {
        if (data.containsKey("token") &&
            data["token"] != null &&
            data["token"].isNotEmpty) {
          String token = data["token"];
          print("✅ Valid token received: ${token.substring(0, 10)}..."); // Log first part for security
          await _storeAuthState(token, true);
          return token;
        } else {
          print("❌ Token missing in response");
          return "Login failed: Token missing";
        }
      } else {
        String errorMessage = data["message"] ?? "Login failed with status code: ${response.statusCode}";
        print("❌ Error response: $errorMessage");
        return errorMessage;
      }
    } catch (error) {
      print("❌ Login Error: $error");
      return "Network error. Please check your internet connection.";
    }
  }

  Future<String> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return "User created successfully"; // Registration successful
      } else if (response.statusCode == 400) {
        return data["message"] ??
            "User already exists. Try logging in."; // Handle user exists message
      } else {
        return "Something went wrong. Please try again.";
      }
    } catch (error) {
      print("Registration Error: $error");
      return "Network error. Please check your internet connection.";
    }
  }

  /// 🔹 Store JWT Token Securely
  Future<void> _storeAuthState(String token, bool isLoggedIn) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("jwt_token", token);
    await prefs.setBool("isLoggedIn", isLoggedIn);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("jwt_token");
    print("🔐 Loaded token: $token");
    return token;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
    await prefs.setBool("isLoggedIn", false);
  }

  Future<bool> isAuthenticated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    String? token = await getToken();

    print("🔒 AuthService.isAuthenticated - isLoggedIn: $isLoggedIn, token exists: ${token != null}");

    return isLoggedIn && token != null && token.isNotEmpty;
  }

  Future<void> resetAuthState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    await prefs.remove("jwt_token");
  }
}
