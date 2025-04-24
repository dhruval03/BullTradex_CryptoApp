import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bulltradex/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
  await Future.delayed(const Duration(seconds: 3)); // splash delay

  final authService = AuthService();
  final isAuthenticated = await authService.isAuthenticated();
  
  // Check consistency of auth state
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  String? token = prefs.getString("jwt_token");
  
  // Fix inconsistent state
  if (isLoggedIn && (token == null || token.isEmpty)) {
    print("🔄 Fixing inconsistent auth state");
    await authService.resetAuthState();
    Navigator.pushReplacementNamed(context, Routes.welcomePage);
    return;
  }
  
  if (isAuthenticated) {
    Navigator.pushReplacementNamed(context, Routes.home);
  } else {
    Navigator.pushReplacementNamed(context, Routes.welcomePage);
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF140519),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.65,
              height: screenHeight * 0.45,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'BullTradex',
              style: TextStyle(
                fontSize: screenWidth * 0.1,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
