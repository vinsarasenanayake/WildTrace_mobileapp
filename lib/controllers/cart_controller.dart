import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

class CartController with ChangeNotifier {
  // cart controller to manage cart with api and local db
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

  // Clear cart contents and reset state after a successful order
  Future<void> resetAfterOrder({String? token}) async {
    await clearCart(token: token);
  }

  // update token when user log in or out, and get cart data if logged in
  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _items.clear();
      if (newToken != null) fetchCart(newToken);
      notifyListeners();
    }
  }

  // Synchronize local cart data with the backend database
  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();

    // try loading from cache only if items are currently empty
    if (_items.isEmpty) {
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
    }

    // Keep track of locally added items that haven't been synced yet
    final List<CartItem> localTempItems = _items.where((item) => item.id?.startsWith('temp_') ?? false).toList();

    try {
      // get cart data from backend
      final List<dynamic> data = await _apiService.fetchCart(token);
      
      // Temporary list for new server data
      final List<CartItem> serverItems = [];
      for (var item in data) {
        final productData = item['product'] ?? item;
        if (productData != null) {
          serverItems.add(
            CartItem(
              id: item['id']?.toString(),
              product: Product.fromJson(productData),
              quantity: (item['quantity'] != null
                      ? num.tryParse(item['quantity'].toString())?.toInt()
                      : 1) ?? 1,
              size: item['size']?.toString(),
              price: item['price'] != null
                  ? double.tryParse(item['price'].toString())
                  : null,
            ),
          );
        }
      }

      _items.clear();
      _items.addAll(serverItems);

      for (var tempItem in localTempItems) {
        bool alreadyOnServer = serverItems.any((si) => 
          si.product.id == tempItem.product.id && 
          si.size == tempItem.size
        );
        if (!alreadyOnServer) {
          _items.add(tempItem);
        }
      }

      // merge pending actions
      final pending = await _dbService.getPendingActions();
      for (var action in pending) {
        if (action['action_type'] == 'cart_add') {
          final actionData = action['data'] is String 
              ? jsonDecode(action['data']) 
              : action['data'];
          final productId = actionData['product_id'];
          final size = actionData['size'];
          
          if (!_items.any((i) => i.product.id == productId && i.size == size)) {
            try {
              Product? product;
              if (actionData['product_json'] != null) {
                product = Product.fromJson(jsonDecode(actionData['product_json']));
              } else {
                final products = await _dbService.getCachedProducts();
                product = products.firstWhere((p) => p.id == productId);
              }
              
              _items.add(CartItem(
                id: 'temp_pending_${action['id']}',
                product: product,
                quantity: actionData['quantity'] ?? 1,
                size: size,
              ));
            } catch (e) {
              debugPrint('Could not restore pending cart item: $e');
            }
          }
        } else if (action['action_type'] == 'cart_remove') {
          final actionData = action['data'] is String ? jsonDecode(action['data']) : action['data'];
          _items.removeWhere((i) => i.id == actionData['id'].toString());
        } else if (action['action_type'] == 'cart_update') {
          final actionData = action['data'] is String ? jsonDecode(action['data']) : action['data'];
          final index = _items.indexWhere((i) => i.id == actionData['id'].toString());
          if (index >= 0) {
            _items[index] = _items[index].copyWith(quantity: actionData['quantity']);
          }
        } else if (action['action_type'] == 'cart_clear') {
          _items.clear();
        }
      }

      // cache update
      await _dbService.cacheCartItems(_items);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Cart API Fetch Error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new product to the shopping cart and update backend
  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? token,
  }) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    // add to local cart immediately for better ui
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    _items.add(
      CartItem(id: tempId, product: product, quantity: quantity, size: size),
    );
    notifyListeners();
    // save the cart to local db immediately
    await _dbService.cacheCartItems(_items);

    try {
      await _apiService.addToCart(product.id, quantity, tokenToUse, size: size);
      await fetchCart(tokenToUse);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Add to Cart API Error: $e');
      }
      await _dbService.addPendingAction('cart_add', {
        'product_id': product.id,
        'product_json': jsonEncode(product.toJson()),
        'quantity': quantity,
        'size': size,
      });
    }
  }

  // Remove a specific item from the shopping cart and update backend
  Future<void> removeFromCart(String cartItemId, {String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    // remove from local cart immediately for better ui
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
    await _dbService.cacheCartItems(_items);

    try {
      await _apiService.removeFromCart(cartItemId, tokenToUse);
      await fetchCart(tokenToUse);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Remove from Cart API Error: $e');
      }
      if (!cartItemId.startsWith('temp_')) {
        await _dbService.addPendingAction('cart_remove', {'id': cartItemId});
      }
    }
  }

  // Adjust the quantity of a specific item in the shopping cart
  Future<void> updateQuantity(
    String cartItemId,
    int quantity, {
    String? token,
  }) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

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
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Update Quantity API Error: $e');
      }
      if (!cartItemId.startsWith('temp_')) {
        await _dbService.addPendingAction('cart_update', {
          'id': cartItemId,
          'quantity': quantity,
        });
      }
    }
  }

  // Increase item quantity by one
  Future<void> incrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) {
      await updateQuantity(item.id!, item.quantity + 1, token: token);
    }
  }

  // Decrease item quantity by one or remove if zero
  Future<void> decrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) {
      if (item.quantity > 1) {
        await updateQuantity(item.id!, item.quantity - 1, token: token);
      } else {
        await removeFromCart(item.id!, token: token);
      }
    }
  }

  // Remove all items from the shopping cart
  Future<void> clearCart({String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;
    
    // clear local cart immediately for better ui
    _items.clear();
    notifyListeners();
    await _dbService.cacheCartItems([]);

    try {
      await _apiService.clearCart(tokenToUse);
      await fetchCart(tokenToUse);
    } catch (e) {
      if (!e.toString().contains('connect to the internet')) {
        debugPrint('Clear Cart Error: $e');
      } else {
        // queue pending action if offline
        await _dbService.addPendingAction('cart_clear', {});
      }
      // Do not rethrow network errors to avoid crashing the UI
    }
  }

  // Check if a specific product exists in the shopping cart
  bool isInCart(String productId) =>
      _items.any((item) => item.product.id == productId);

  // Retrieve current quantity of a specific product in cart
  int getQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
