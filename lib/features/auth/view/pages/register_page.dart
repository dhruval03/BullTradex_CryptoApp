import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:bulltradex/features/auth/view/widgets/auth_button.dart';
import 'package:bulltradex/features/auth/view/widgets/auth_card.dart';
import 'package:bulltradex/features/auth/view/widgets/custom_text_field.dart';
import 'package:bulltradex/core/utils/validators.dart';
import 'package:bulltradex/routes/routes.dart';
import 'package:bulltradex/features/auth/data/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isRegisterSuccess = false;
  bool _isLoading = false; // New state variable for loading state

  void _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });
    
    AuthService authService = AuthService();
    try {
      print("🔑 Attempting registration...");
      String message = await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (message == "User created successfully") {
        setState(() {
          _isRegisterSuccess = true;
          _isLoading = false;
        });

        print("✅ Registration successful");
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, Routes.loginPage);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print("❌ Registration failed: $message");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)), // Display dynamic error message
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("❌ Registration error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sign up to get started",
                      style: TextStyle(
                        fontSize: width * 0.045,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    AuthCard(
                      child: Column(
                        children: [
                          CustomTextField(
                            label: "Full Name",
                            icon: Icons.person,
                            controller: _nameController,
                            validator: (value) =>
                                value!.isEmpty ? "Enter your name" : null,
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            label: "Email",
                            icon: Icons.email,
                            controller: _emailController,
                            validator: (value) =>
                                Validators.validateEmail(value, context),
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            label: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                            controller: _passwordController,
                            validator: (value) =>
                                Validators.validatePassword(value, context),
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            label: "Confirm Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller: _confirmPasswordController,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 20),
                          // Replace the standard AuthButton with our custom loader button
                          _buildRegisterButton(),
                          const SizedBox(height: 20),
                          AuthButton(
                            text: "Continue with Google",
                            iconPath: "assets/images/auth/google.png",
                            isOutlined: true,
                            onPressed: () {},
                          ),
                          const SizedBox(height: 10),
                          AuthButton(
                            text: "Continue with Apple",
                            iconPath: "assets/images/auth/apple.png",
                            isOutlined: true,
                            onPressed: () {},
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, Routes.loginPage);
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRegisterButton() {
    if (_isLoading) {
      // Show loading spinner when loading
      return Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    } else {
      // Show regular AuthButton when not loading
      return AuthButton(
        text: _isRegisterSuccess ? "Registration Successful!" : "Register",
        onPressed: _register,
        isSuccess: _isRegisterSuccess,
      );
    }
  }
}