// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';

// ============================================================================
// NAVIGATION PROVIDER - Bottom Navigation State Management
// ============================================================================
class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
