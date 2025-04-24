import 'package:bulltradex/core/providers/navigation_provider.dart';
import 'package:bulltradex/core/providers/theme_provider.dart';
import 'package:bulltradex/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:bulltradex/routes/routes.dart';
import 'package:bulltradex/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Important for async operations in main
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'BullTradex',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, // ✅ Now it's defined
            home: SplashScreen(),
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
