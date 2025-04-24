// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:bulltradex/splash_screen.dart';
import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:bulltradex/features/auth/view/pages/login_page.dart';
import 'package:bulltradex/features/home/view/pages/home_screen.dart';
import 'package:bulltradex/features/auth/view/pages/welcome_page.dart'; // Update this to the correct existing file
import 'package:bulltradex/features/auth/view/pages/register_page.dart';

class Routes {
  static const String splash = '/';
  static const String welcomePage = '/welcomePage';
  static const String registerPage = '/registerPage';
  static const String loginPage = '/loginPage';
  static const String home = '/home';

  static Future<String> getInitialRoute() async {
    AuthService authService = AuthService();
    bool isAuthenticated = await authService.isAuthenticated();
    return isAuthenticated ? home : loginPage;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case welcomePage:
        return MaterialPageRoute(builder: (_) => WelcomePage());
      case registerPage:
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case loginPage:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}