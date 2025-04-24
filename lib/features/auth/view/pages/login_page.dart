import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:bulltradex/features/auth/view/widgets/auth_button.dart';
import 'package:bulltradex/features/auth/view/widgets/auth_card.dart';
import 'package:bulltradex/features/auth/view/widgets/custom_text_field.dart';
import 'package:bulltradex/core/utils/validators.dart';
import 'package:bulltradex/routes/routes.dart';
import 'package:http/http.dart' as http;
import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSuccess = false; // To track if login is successful
  bool _isLoading = false; // To track loading state

  void _login() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });
    
    AuthService authService = AuthService();
    try {
      print("🔑 Attempting login...");
      String? result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Check if the result contains error messages
      if (result != null && 
          !result.toLowerCase().contains("invalid") && 
          !result.toLowerCase().contains("failed") && 
          !result.toLowerCase().contains("error")) {
        
        print("🔑 Login successful, checking token storage...");
        
        // Verify token was stored
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
        String? storedToken = prefs.getString("jwt_token");
        
        print("🔑 Stored values - isLoggedIn: $isLoggedIn, token exists: ${storedToken != null && storedToken.isNotEmpty}");
        
        if (isLoggedIn && storedToken != null && storedToken.isNotEmpty) {
          // Set success state before navigation
          setState(() {
            _isSuccess = true;
            _isLoading = false;
          });
          
          print("✅ Authentication confirmed, navigating to home");
          // Add a small delay to show the success state
          await Future.delayed(Duration(milliseconds: 500));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.home, (route) => false);
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          print("❌ Token storage verification failed");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: Could not store authentication")),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        print("❌ Login failed: $result");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result ?? "Login failed")),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("❌ Login error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
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
                      "Welcome to BullTradex",
                      style: TextStyle(
                        fontSize: width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
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
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Modified AuthButton with loading state
                          _buildLoginButton(),
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
                                "Don't have an account? ",
                                style: TextStyle(fontSize: 14),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, Routes.registerPage);
                                },
                                child: Text(
                                  "Register",
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
  
  Widget _buildLoginButton() {
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
        text: _isSuccess ? "Login Successful!" : "Login",
        onPressed: _login,
        isSuccess: _isSuccess,
      );
    }
  }
}