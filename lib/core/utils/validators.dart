import 'package:flutter/material.dart';

class Validators {
  // Error messages for validations
  static const String emailRequiredMessage = "Email is required";
  static const String invalidEmailMessage = "Invalid email format";
  static const String passwordRequiredMessage = "Password is required";
  static const String passwordComplexityMessage =
      "Password must be at least 8 characters long, contain at least 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character";

  // Regex patterns
  static final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
  static final RegExp passwordComplexityRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');

  // Enhanced SnackBar for Email Validation
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      _showSnackBar(context, emailRequiredMessage, Colors.redAccent);
      return "";
    }
    if (!emailRegex.hasMatch(value)) {
      _showSnackBar(context, invalidEmailMessage, Colors.orangeAccent);
      return "";
    }
    return null;
  }

  // Enhanced SnackBar for Password Validation
  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      _showSnackBar(context, passwordRequiredMessage, Colors.redAccent);
      return "";
    }

    // Improved password complexity validation with more feedback
    if (!passwordComplexityRegex.hasMatch(value)) {
      _showSnackBar(
        context,
        passwordComplexityMessage,
        Colors.orangeAccent,
      );
      return "";
    }

    return null;
  }

  // Method to show powerful and attractive SnackBar
  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: backgroundColor,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          textColor: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
