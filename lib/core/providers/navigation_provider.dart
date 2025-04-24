import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  // Getter for selected index
  int get selectedIndex => _selectedIndex;

  // Method to update the selected index and notify listeners
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {  // Only update if the value is different
      _selectedIndex = index;
      notifyListeners();  // Rebuild listeners when index changes
    }
  }
}
