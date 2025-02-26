import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:bulltradex/features/auth/view/widgets/auth_button.dart';
import 'package:bulltradex/features/auth/view/widgets/auth_card.dart';
import 'package:bulltradex/features/auth/view/widgets/custom_text_field.dart';
import 'package:bulltradex/core/utils/validators.dart';
import 'package:bulltradex/routes/routes.dart';
import 'package:http/http.dart' as http;

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

  void _login() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isSuccess = true;
      Navigator.pushReplacementNamed(context, Routes.home);
    });

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Handle login success (e.g., store token and navigate to Home)
      final data = json.decode(response.body);
      print(data['message']);
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      // Handle error (e.g., show error message)
      print('Login failed: ${response.body}');
    }
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
                            validator: (value) => Validators.validateEmail(value, context),
                          ),
                          const SizedBox(height: 15),
                          CustomTextField(
                            label: "Password",
                            icon: Icons.lock,
                            isPassword: true,
                            controller: _passwordController,
                            validator: (value) => Validators.validatePassword(value, context),
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
                          AuthButton(
                            text: _isSuccess ? "Login Successful!" : "Login",
                            onPressed: _login,
                            isSuccess: _isSuccess,
                          ),
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
                                onPressed: () {},
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
}
