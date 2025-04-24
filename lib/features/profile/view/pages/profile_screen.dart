import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:bulltradex/features/profile/view/pages/PersonalInfoScreen.dart';
import 'package:bulltradex/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:bulltradex/core/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = await _authService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('http://192.168.49.134:5000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _userData = responseBody;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      // If token is invalid, force logout
      if (e.toString().contains('403')) {
        await _authService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.loginPage, (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildProfileHeader(textColor),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.person,
                      title: "Personal Info",
                      textColor: textColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PersonalInfoScreen(userData: _userData ?? {}),
                          ),
                        );
                      },
                    ),
                    _buildTile(
                      icon: Icons.notifications,
                      title: "Notification",
                      textColor: textColor,
                      onTap: () {},
                    ),
                    _buildTile(
                      icon: Icons.language,
                      title: "Language",
                      textColor: textColor,
                      trailing: const Text("English (US)"),
                      onTap: () {},
                    ),
                    _buildDarkModeTile(context),
                    _buildTile(
                      icon: Icons.help_outline,
                      title: "Help Center",
                      textColor: textColor,
                      onTap: () {},
                    ),
                    _buildTile(
                      icon: Icons.logout,
                      title: "Logout",
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () async {
                        final authService = AuthService();
                        await authService.logout();
                        Navigator.pushNamedAndRemoveUntil(
                            context, Routes.loginPage, (route) => false);
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildProfileHeader(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: _userData?['profile_image_url'] != null
                  ? NetworkImage(_userData!['profile_image_url'])
                  : const AssetImage('assets/images/user_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData?['name'] ?? 'Loading...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                Text(
                  _userData?['email'] ?? 'loading...',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: AppColors.cardGradient,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.people, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Refer your friends & earn up to 25% commission when they trade!",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: iconColor ?? AppColors.lightPrimary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? AppColors.lightText,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeTile(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return SwitchListTile(
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (val) {
        themeProvider.toggledTheme(val ? ThemeMode.dark : ThemeMode.light);
      },
      title: Text(
        "Dark Mode",
        style: TextStyle(color: textColor),
      ),
      secondary: const Icon(Icons.dark_mode),
    );
  }

  Widget _buildDivider() {
    return const Divider(thickness: 1.2, height: 32);
  }
}
