import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:bulltradex/core/providers/navigation_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const HomeAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: navigationProvider.selectedIndex == 0
          ? null
          : IconButton(
              icon: const Icon(Icons.arrow_back_sharp, color: Colors.white),
              onPressed: () => navigationProvider.setSelectedIndex(0),
            ),
      backgroundColor: AppColors.lightPrimary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
