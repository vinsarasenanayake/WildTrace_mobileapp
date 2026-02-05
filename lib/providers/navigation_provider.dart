import 'package:flutter/material.dart';

// manages bottom navigation state
class NavigationProvider with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  // updates tab index
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
