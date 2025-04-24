import 'package:flutter/material.dart';
import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:bulltradex/routes/routes.dart';

class AuthCheckWrapper extends StatefulWidget {
  final Widget child;
  
  const AuthCheckWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _AuthCheckWrapperState createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<AuthCheckWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    bool authenticated = await _authService.isAuthenticated();
    
    setState(() {
      _isAuthenticated = authenticated;
      _isLoading = false;
    });
    
    if (!_isAuthenticated) {
      // Only navigate if we're in a mounted widget
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.loginPage, 
          (route) => false
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return widget.child;
  }
}