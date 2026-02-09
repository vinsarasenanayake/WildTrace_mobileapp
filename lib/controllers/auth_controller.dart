import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api/index.dart';

//authentication controller
class AuthController with ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  UserModel? _currentUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthController() {
    checkAuthStatus();
  }

  //save data in local storage
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Authenticate user credentials with the backend api
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      // authenticate with api
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

  // Register a new user account with the provided details
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
      // send registration data to backend
      await _apiService.register(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear all user session data and remove local authentication storage
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    notifyListeners();
  }

  // Update existing user profile information with backend api
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
      // send updated profile data to backend
      final response = await _apiService.updateUserProfile(
        profileData,
        _token!,
      );
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
      rethrow;
    }
  }

  // Check for existing user session data in local terminal storage
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load saved authentication data from local storage
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(_tokenKey);
      final savedUserJson = prefs.getString(_userKey);
      if (savedToken != null && savedUserJson != null) {
        _token = savedToken;
        _currentUser = UserModel.fromJson(json.decode(savedUserJson));
        _isAuthenticated = true;
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuthData() async {
    if (_token != null && _currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
    }
  }
}
