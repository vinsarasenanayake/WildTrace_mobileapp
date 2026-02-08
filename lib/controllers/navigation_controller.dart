import 'package:flutter/material.dart';

// navigation controller
class NavigationController with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  NavigationController({int initialIndex = 0}) {
    _selectedIndex = initialIndex;
  }

  // set tab index
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
