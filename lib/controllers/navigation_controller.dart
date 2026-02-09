import 'package:flutter/material.dart';

class NavigationController with ChangeNotifier {
  // controller to manage bottom navigation bar
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  NavigationController({int initialIndex = 0}) {
    _selectedIndex = initialIndex;
  }

  // Update the active navigation index and refresh ui
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
