import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final String? iconPath;
  final bool isSuccess; // To handle success state

  const AuthButton({
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.iconPath,
    this.isSuccess = false, // Default to false for the initial state
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSuccess ? Colors.green : (isOutlined ? Colors.transparent : Colors.blue[900]),
          borderRadius: BorderRadius.circular(10),
          border: isOutlined ? Border.all(color: Colors.blue) : null,
        ),
        child: isOutlined
            ? OutlinedButton.icon(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: iconPath != null
                    ? Image.asset(iconPath!, height: 28)
                    : const SizedBox(),
                label: Text(
                  text,
                  style: TextStyle(fontSize: 16.5, color: isSuccess ? Colors.white : Colors.black),
                ),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : Colors.blue[900],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSuccess)
                      Icon(Icons.check, color: Colors.white), // Checkmark icon for success
                    SizedBox(width: isSuccess ? 10 : 0),
                    Text(
                      text,
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
