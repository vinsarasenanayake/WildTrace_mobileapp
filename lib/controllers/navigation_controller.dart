import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// manages bottom navigation state with persistence
class NavigationController with ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  NavigationController({int initialIndex = 0}) {
    _selectedIndex = initialIndex;
    _loadSavedIndex();
  }

  // load last visited tab from storage
  Future<void> _loadSavedIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedIndex = prefs.getInt('last_nav_index') ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  // updates tab index and persists it
  void setSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
      _saveIndex(index);
    }
  }

  Future<void> _saveIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_nav_index', index);
    } catch (_) {}
  }
}
