// Imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

// Auth Provider
class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  // State variables for authentication
  UserModel? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  // Initialization
  AuthProvider() {
    checkAuthStatus();
  }

  // Persistence Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Sign in with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      _token = response['token'];
      if (response['user'] != null) {
        _currentUser = UserModel.fromJson(response['user']);
        _isAuthenticated = true;
        await _saveAuthData();
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Create a new user account
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
      final Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'contact_number': contactNumber,
        'address': address,
        'city': city,
        'postal_code': postalCode,
        'country': country,
      };

      final response = await _apiService.register(userData);
      
      _token = response['token'];
      if (response['user'] != null) {
        _currentUser = UserModel.fromJson(response['user']);
        _isAuthenticated = true;
        await _saveAuthData();
      }

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
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  // Update user details in the database
  Future<bool> updateProfile(UserModel updatedUser) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> profileData = {
        'name': updatedUser.name,
        'email': updatedUser.email,
        'contact_number': updatedUser.contactNumber,
        'address': updatedUser.address,
        'city': updatedUser.city,
        'postal_code': updatedUser.postalCode,
        'country': updatedUser.country,
      };

      final response = await _apiService.updateUserProfile(profileData, _token!);
      
      if (response['user'] != null) {
         _currentUser = UserModel.fromJson(response['user']);
         await _saveAuthData();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Local storage management for persistent login
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUserJson = prefs.getString(_userKey);

      if (savedToken != null && savedUserJson != null) {
        _token = savedToken;
        _currentUser = UserModel.fromJson(json.decode(savedUserJson));
        _isAuthenticated = true;

      }
    } catch (e) {

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save Auth Data
  Future<void> _saveAuthData() async {
    if (_token != null && _currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
    }
  }
}
