// ============================================================================
// FAVORITES PROVIDER - Favorites State Management
// ============================================================================
import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => List.unmodifiable(_favorites);

  int get count => _favorites.length;

  bool get isEmpty => _favorites.isEmpty;

  // Toggle favorite status
  void toggleFavorite(Product product) {
    final index = _favorites.indexWhere((p) => p.id == product.id);
    
    if (index >= 0) {
      _favorites.removeAt(index);
      product.isFavorite = false;
    } else {
      _favorites.add(product.copyWith(isFavorite: true));
      product.isFavorite = true;
    }
    notifyListeners();
  }

  // Add to favorites
  void addToFavorites(Product product) {
    if (!isFavorite(product.id)) {
      _favorites.add(product.copyWith(isFavorite: true));
      product.isFavorite = true;
      notifyListeners();
    }
  }

  // Remove from favorites
  void removeFromFavorites(String productId) {
    final index = _favorites.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _favorites[index].isFavorite = false;
      _favorites.removeAt(index);
      notifyListeners();
    }
  }

  // Check if product is favorite
  bool isFavorite(String productId) {
    return _favorites.any((p) => p.id == productId);
  }

  // Clear all favorites
  void clearFavorites() {
    for (var product in _favorites) {
      product.isFavorite = false;
    }
    _favorites.clear();
    notifyListeners();
  }
}
