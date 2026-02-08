import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

class CartController with ChangeNotifier {
  final CartApiService _apiService = CartApiService();
  final DatabaseService _dbService = DatabaseService();
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _token;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => 0.0;
  double get shipping => 0.0;
  double get total => subtotal + tax + shipping;
  double get totalAmount => total;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;

  Future<void> resetAfterOrder({String? token}) async {
    await clearCart(token: token);
  }

  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _items.clear();
      if (newToken != null) fetchCart(newToken);
      notifyListeners();
    }
  }

  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();

    // try loading from cache
    try {
      final cached = await _dbService.getCachedCartItems();
      if (cached.isNotEmpty) {
        _items.clear();
        _items.addAll(cached);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Cart Cache Error: $e');
    }

    try {
      final List<dynamic> data = await _apiService.fetchCart(token);
      _items.clear();
      for (var item in data) {
         final productData = item['product'] ?? item;
         if (productData != null) {
           _items.add(CartItem(
             id: item['id']?.toString(), 
             product: Product.fromJson(productData),
             quantity: (item['quantity'] != null ? num.tryParse(item['quantity'].toString())?.toInt() : 1) ?? 1,
             size: item['size']?.toString(),
             price: item['price'] != null ? double.tryParse(item['price'].toString()) : null,
           ));
         }
      }
      // update cache
      await _dbService.cacheCartItems(_items);
    } catch (e) {
      debugPrint('Cart Error: $e');
      if (_items.isEmpty) rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> addToCart(Product product, {int quantity = 1, String? size, String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;
    
    // OPTIMISTIC UPDATE: Update local list and cache immediately for 
    // instant UI feedback, even if the user is offline.
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    _items.add(CartItem(
      id: tempId,
      product: product,
      quantity: quantity,
      size: size,
    ));
    notifyListeners();
    await _dbService.cacheCartItems(_items);

    try {
      await _apiService.addToCart(product.id, quantity, tokenToUse, size: size);
      await fetchCart(tokenToUse);
    } catch (e) {
      debugPrint('Add to Cart API Error: $e');
      // FAILSILENT OFFLINE: If API fails (e.g. No Internet), save the action 
      // locally. It will be synced by SyncController once connection returns.
      await _dbService.addPendingAction('cart_add', {
        'product_id': product.id,
        'quantity': quantity,
        'size': size,
      });
    }
  }

  Future<void> removeFromCart(String cartItemId, {String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;
    
    // optimistic update
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
    await _dbService.cacheCartItems(_items);

    try {
      await _apiService.removeFromCart(cartItemId, tokenToUse);
      await fetchCart(tokenToUse);
    } catch (e) {
      debugPrint('Remove from Cart API Error: $e');
      if (!cartItemId.startsWith('temp_')) {
        await _dbService.addPendingAction('cart_remove', {'id': cartItemId});
      }
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity, {String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    // optimistic update
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
      await _dbService.cacheCartItems(_items);
    }

    try {
      if (quantity <= 0) {
        await _apiService.removeFromCart(cartItemId, tokenToUse);
      } else {
        await _apiService.updateCartItem(cartItemId, quantity, tokenToUse);
      }
      await fetchCart(tokenToUse);
    } catch (e) {
      debugPrint('Update Quantity API Error: $e');
      if (!cartItemId.startsWith('temp_')) {
        await _dbService.addPendingAction('cart_update', {'id': cartItemId, 'quantity': quantity});
      }
    }
  }

  Future<void> incrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) await updateQuantity(item.id!, item.quantity + 1, token: token);
  }

  Future<void> decrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) {
      if (item.quantity > 1) {
        await updateQuantity(item.id!, item.quantity - 1, token: token);
      } else {
        await removeFromCart(item.id!, token: token);
      }
    }
  }

  Future<void> clearCart({String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;
    try {
      await _apiService.clearCart(tokenToUse);
      await fetchCart(tokenToUse);
    } catch (e) {
      debugPrint('Clear Cart Error: $e');
      rethrow;
    }
  }

  bool isInCart(String productId) => _items.any((item) => item.product.id == productId);

  int getQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
