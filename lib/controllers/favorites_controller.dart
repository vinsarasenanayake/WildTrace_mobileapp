import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// favorite items manager
class FavoritesController with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Product> _favorites = [];
  bool _isLoading = false;
  String? _token;

  List<Product> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;
  bool get isEmpty => _favorites.isEmpty;
  bool get isLoading => _isLoading;

  // updates session token
  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _favorites.clear();
      if (newToken != null) fetchFavorites(newToken);
      notifyListeners();
    }
  }

  // gets favorites from server
  Future<void> fetchFavorites(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<Product> fetchedFavorites = await _apiService.fetchFavorites(token);
      _favorites.clear();
      _favorites.addAll(fetchedFavorites.map((p) => p.copyWith(isFavorite: true)));
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // toggles favorite status
  Future<void> toggleFavorite(Product product, {String? token}) async {
    final tokenToUse = token ?? _token;
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
      await fetchFavorites(tokenToUse);
    }
  }

  // adds to local favorites
  void addToFavorites(Product product) {
    if (!isFavorite(product.id)) {
      _favorites.add(product.copyWith(isFavorite: true));
      product.isFavorite = true;
      notifyListeners();
    }
  }

  // removes from local favorites
  void removeFromFavorites(String productId) {
    final index = _favorites.indexWhere((p) => p.id == productId);
    if (index >= 0) {
      _favorites[index].isFavorite = false;
      _favorites.removeAt(index);
      notifyListeners();
    }
  }

  // checks favorite status
  bool isFavorite(String productId) => _favorites.any((p) => p.id == productId);

  // clears local favorites
  void clearFavorites() {
    for (var product in _favorites) {
      product.isFavorite = false;
    }
    _favorites.clear();
    notifyListeners();
  }
}
