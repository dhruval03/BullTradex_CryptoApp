import 'package:flutter/material.dart';
import 'package:bulltradex/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Navigate to home screen after splash screen duration
  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, Routes.welcomePage);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF140519), // Fix incorrect color format
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.65, // 50% of screen width
              height: screenHeight * 0.45, // 30% of screen height
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.02), // Dynamic spacing
            Text(
              'BullTradex',
              style: TextStyle(
                fontSize: screenWidth * 0.1, // 10% of screen width
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