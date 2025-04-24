import 'package:flutter/material.dart';
import 'package:bulltradex/core/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:bulltradex/features/auth/data/auth_service.dart';
import 'package:path/path.dart' as path;
import 'package:bulltradex/core/utils/validators.dart'; // Import your Validators

class PersonalInfoScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const PersonalInfoScreen({
    super.key, 
    required this.userData,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isImageLoading = false;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  void _showValidationSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_selectedImage == null) return;

    setState(() => _isImageLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.49.134:5000/api/user/profile/image'),
      )
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath(
          'profileImage',
          _selectedImage!.path,
          filename: path.basename(_selectedImage!.path),
        ));

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return success
      } else {
        throw Exception(jsonDecode(responseData)['message'] ?? 'Upload failed');
      }
    } catch (e) {
      _showValidationSnackBar(e.toString(), Colors.redAccent);
    } finally {
      setState(() => _isImageLoading = false);
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    // Manually validate email using the regex from Validators
    if (_emailController.text.isEmpty) {
      _showValidationSnackBar(Validators.emailRequiredMessage, Colors.redAccent);
      return;
    }
    if (!Validators.emailRegex.hasMatch(_emailController.text)) {
      _showValidationSnackBar(Validators.invalidEmailMessage, Colors.orangeAccent);
      return;
    }

    // Manually validate password if not empty
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text.isEmpty) {
        _showValidationSnackBar(Validators.passwordRequiredMessage, Colors.redAccent);
        return;
      }
      if (!Validators.passwordComplexityRegex.hasMatch(_passwordController.text)) {
        _showValidationSnackBar(Validators.passwordComplexityMessage, Colors.orangeAccent);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.put(
        Uri.parse('http://192.168.49.134:5000/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          if (_passwordController.text.isNotEmpty)
            'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // Return success
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Update failed');
      }
    } catch (e) {
      _showValidationSnackBar(e.toString(), Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : widget.userData['profile_image_url'] != null
                            ? NetworkImage(widget.userData['profile_image_url'])
                            : const AssetImage('assets/images/user_avatar.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, color: primaryColor),
                      onPressed: _isImageLoading ? null : _pickImage,
                    ),
                  ),
                ],
              ),
            ),
            
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isImageLoading ? null : () => _uploadImage(context),
                child: _isImageLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Image'),
              ),
              const SizedBox(height: 24),
            ],
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: textColor.withOpacity(0.3)),
                ),
              ),
              style: TextStyle(color: textColor),
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            
            const SizedBox(height: 16),
            
            // Email Field (using Validators)
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: textColor.withOpacity(0.3)),
                ),
              ),
              style: TextStyle(color: textColor),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 16),
            
            // Password Field (using Validators)
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password (leave blank to keep current)',
                labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
              ),
              style: TextStyle(color: textColor),
              obscureText: true,
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : () => _updateProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}