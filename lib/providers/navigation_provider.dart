// Imports
import 'package:flutter/material.dart';

// Navigation Provider
class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  // Set Selected Index
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
