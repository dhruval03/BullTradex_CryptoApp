import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bulltradex/core/providers/navigation_provider.dart';
import 'package:bulltradex/features/home/view/widgets/home_app_bar.dart';
import 'package:bulltradex/features/home/view/widgets/home_bottom_nav_bar.dart';
import 'package:bulltradex/features/home/view/widgets/home_content.dart';
import 'package:bulltradex/features/market/view/pages/market_screen.dart';
import 'package:bulltradex/features/news/view/pages/news_screen.dart';
import 'package:bulltradex/features/profile/view/pages/profile_screen.dart';
import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:bulltradex/routes/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastBackPressTime;
  bool _isLoading = true;

  final List<Widget> _pages = const [
    HomeContent(),
    MarketScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = ['Home', 'Market', 'News', 'Profile'];

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final authService = AuthService();
    bool isAuthenticated = await authService.isAuthenticated();

    if (!isAuthenticated && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.loginPage, (route) => false);
      return;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    final now = DateTime.now();

    if (navigationProvider.selectedIndex != 0) {
      navigationProvider.setSelectedIndex(0);
      return false;
    }

    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Press again to exit"), duration: Duration(seconds: 2)),
      );
      return false;
    }

    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: HomeAppBar(title: _titles[navigationProvider.selectedIndex]),
            body: IndexedStack(
              index: navigationProvider.selectedIndex,
              children: _pages,
            ),
            bottomNavigationBar: HomeBottomNavBar(currentIndex: navigationProvider.selectedIndex),
          ),
        );
      },
    );
  }
}
