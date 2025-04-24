import 'package:bulltradex/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;

            return Column(
              children: [
                // Top Image (Takes up 55% of the screen height)
                Expanded(
                  flex: 5,
                  child: Image.asset(
                    'assets/images/welcom.jpg', // Replace with actual image
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10), // Space between image and text

                // Text Section (Title & Subtitle)
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Let's Start Something big with BullTradex!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: width * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                        child: Text(
                          "Stay ahead in the crypto world with real-time data, expert insights, and the latest news.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: AppColors.lightText.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Pushes buttons to bottom

                // Buttons Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Login Button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.loginPage);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Register Button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black54),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Handle register
                            Navigator.pushNamed(context, Routes.registerPage);
                          },
                          child: const Text(
                            "Register",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // Bottom padding
              ],
            );
          },
        ),
      ),
    );
  }
}
