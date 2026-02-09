import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

class FavoritesController with ChangeNotifier {
  // controller to manage favorite products with api and local db
  final CartApiService _apiService = CartApiService();
  final DatabaseService _dbService = DatabaseService();
  final List<Product> _favorites = [];
  bool _isLoading = false;
  String? _token;

  List<Product> get favorites => List.unmodifiable(_favorites);
  int get count => _favorites.length;
  bool get isEmpty => _favorites.isEmpty;
  bool get isLoading => _isLoading;

  // Update session token and refresh favorites list
  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _favorites.clear();
      if (newToken != null) fetchFavorites(newToken);
      notifyListeners();
    }
  }

  // Retrieve favorited products and synchronize with local cache
  Future<void> fetchFavorites(String token) async {
    _isLoading = true;
    notifyListeners();

    // try loading cached product IDs and matching with cached products if empty
    if (_favorites.isEmpty) {
      try {
        final cachedIds = await _dbService.getCachedFavorites();
        final allCachedProducts = await _dbService.getCachedProducts();
        final cachedFavs = allCachedProducts
            .where((p) => cachedIds.contains(p.id))
            .toList();

        if (cachedFavs.isNotEmpty) {
          _favorites.clear();
          _favorites.addAll(cachedFavs.map((p) => p.copyWith(isFavorite: true)));
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Favorites Cache Error: $e');
      }
    }

    try {
      // get favorite products data from backend
      final List<Product> fetchedFavorites = await _apiService.fetchFavorites(token);
      
      // Update our list with the backend data
      _favorites.clear();
      _favorites.addAll(fetchedFavorites.map((p) => p.copyWith(isFavorite: true)));

      // Merge pending actions
      final pending = await _dbService.getPendingActions();
      for (var action in pending) {
        if (action['action_type'] == 'favorite_toggle') {
          final actionData = action['data'] is String ? jsonDecode(action['data']) : action['data'];
          final productId = actionData['id'];
          
          final index = _favorites.indexWhere((p) => p.id == productId);
          if (index >= 0) {
            _favorites.removeAt(index);
          } else {
            try {
              Product? product;
              if (actionData['product_json'] != null) {
                product = Product.fromJson(jsonDecode(actionData['product_json']));
              } else {
                final products = await _dbService.getCachedProducts();
                product = products.firstWhere((p) => p.id == productId);
              }
              _favorites.add(product.copyWith(isFavorite: true));
            } catch (e) {
              debugPrint('Could not restore pending favorite: $e');
            }
          }
        }
      }

      await _dbService.cacheFavorites(_favorites.map((p) => p.id).toList());
      await _dbService.cacheProducts(_favorites);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Favorites API Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add or remove a product from favorites and update backend
  Future<void> toggleFavorite(Product product, {String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;
    try {
      final index = _favorites.indexWhere((p) => p.id == product.id);
      final isNowFavorite = index < 0;

      // immediately update UI
      if (!isNowFavorite) {
        _favorites.removeAt(index);
      } else {
        _favorites.add(product.copyWith(isFavorite: true));
      }
      notifyListeners();

      // Ensure local database so local db is consistent
      await _dbService.toggleFavoriteLocal(product.id, isNowFavorite);

      await _apiService.toggleFavorite(product.id, tokenToUse);
      fetchFavorites(tokenToUse);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Toggle Favorite API Error: $e');
      }
      await _dbService.addPendingAction('favorite_toggle', {
        'id': product.id,
        'product_json': jsonEncode(product.toJson()),
      });
    }
  }

  // Check if a specific product is marked as favorite
  bool isFavorite(String productId) => _favorites.any((p) => p.id == productId);

  // Reset all favorites on user logout
  void clearFavorites() {
    for (var product in _favorites) {
      product.isFavorite = false;
    }
    _favorites.clear();
    notifyListeners();
  }
}
