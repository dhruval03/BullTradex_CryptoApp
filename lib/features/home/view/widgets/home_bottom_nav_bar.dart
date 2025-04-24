import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bulltradex/core/widgets/bottom_nav_bar.dart';
import 'package:bulltradex/core/providers/navigation_provider.dart';
import 'package:bulltradex/core/theme/colors.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const HomeBottomNavBar({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    return BottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) => navigationProvider.setSelectedIndex(index),
      backgroundColor: AppColors.lightPrimary,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    );
  }
}
