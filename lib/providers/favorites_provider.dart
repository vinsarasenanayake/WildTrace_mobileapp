// Imports
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// Favorites Provider
class FavoritesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Product> _favorites = [];
  bool _isLoading = false;
  String? _token;

  List<Product> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;
  bool get isEmpty => _favorites.isEmpty;
  bool get isLoading => _isLoading;

  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _favorites.clear();
      if (newToken != null) {
        fetchFavorites(newToken);
      }
      notifyListeners();
    }
  }

  // Fetch Favorites
  Future<void> fetchFavorites(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<Product> fetchedFavorites = await _apiService.fetchFavorites(token);
      _favorites.clear();
      _favorites.addAll(fetchedFavorites.map((p) => p.copyWith(isFavorite: true)));
    } catch (e) {
      debugPrint('Error fetching favorites: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle Favorite
  Future<void> toggleFavorite(Product product) async {
    final tokenToUse = _token;
    if (tokenToUse == null) return;

    try {
      final index = _favorites.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _favorites.removeAt(index);
      } else {
        _favorites.add(product.copyWith(isFavorite: true));
      }
      notifyListeners();

      await _apiService.toggleFavorite(product.id, tokenToUse);
      
      await fetchFavorites(tokenToUse);
    } catch (e) {
      debugPrint('Error toggling favorite on API: $e');
      await fetchFavorites(tokenToUse);
    }
  }

  // Add to Favorites
  void addToFavorites(Product product) {
    if (!isFavorite(product.id)) {
      _favorites.add(product.copyWith(isFavorite: true));
      product.isFavorite = true;
      notifyListeners();
    }
  }

  // Remove from Favorites
  void removeFromFavorites(String productId) {
    final index = _favorites.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _favorites[index].isFavorite = false;
      _favorites.removeAt(index);
      notifyListeners();
    }
  }

  // Is Favorite
  bool isFavorite(String productId) {
    return _favorites.any((p) => p.id == productId);
  }

  // Clear Favorites
  void clearFavorites() {
    for (var product in _favorites) {
      product.isFavorite = false;
    }
    _favorites.clear();
    notifyListeners();
  }
}
