import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to store if user has seen the splash screen
final splashScreenSeenProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_splash') ?? false;
});

// Provider to update the splash screen flag
final setSplashScreenSeenProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('has_seen_splash', true);
});
