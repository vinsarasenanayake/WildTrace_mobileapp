// ============================================================================
// AUTH PROVIDER - Authentication State Management
// ============================================================================
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual authentication logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Mock user data
      _currentUser = UserModel(
        id: '1',
        name: 'John Doe',
        email: email,
        contactNumber: '+1234567890',
        address: '123 Main St',
        city: 'New York',
        postalCode: '10001',
        country: 'United States',
      );

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? contactNumber,
    String? address,
    String? city,
    String? postalCode,
    String? country,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual registration logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _currentUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        contactNumber: contactNumber,
        address: address,
        city: city,
        postalCode: postalCode,
        country: country,
      );

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement actual update logic
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check authentication status
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Check if user is logged in (e.g., check token)
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, assume not authenticated
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
