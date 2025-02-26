// lib/screens/home_screen.dart
import 'package:bulltradex/core/theme/colors.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppColors.cardGradient),),
        title: const Text('Home',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to BullTradex!',
              style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)), 
            ),
          ],
        ),
      ),
    );
  }
}