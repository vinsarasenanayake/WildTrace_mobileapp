// Imports
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// Cart Provider
class CartProvider with ChangeNotifier {
  // State variables for the shopping cart
  final ApiService _apiService = ApiService();
  final List<CartItem> _items = [];
  bool _isLoading = false;
  String? _token;

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get tax => 0.0;
  double get shipping => 0.0;
  double get total => subtotal;
  double get totalAmount => total;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;

  // Update auth token and refresh cart items
  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _items.clear();
      if (newToken != null) {
        fetchCart(newToken);
      }
      notifyListeners();
    }
  }

  // Fetch current cart from the server
  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();
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
    } catch (e) {

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a product with specific size to the cart
  Future<void> addToCart(Product product, {int quantity = 1, String? size, double? price, String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    try {
      await _apiService.addToCart(product.id, quantity, tokenToUse, size: size);
      
      await fetchCart(tokenToUse);
    } catch (e) {

    }
  }

  // Remove from Cart
  Future<void> removeFromCart(String cartItemId, {String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    try {
      await _apiService.removeFromCart(cartItemId, tokenToUse);
      
      await fetchCart(tokenToUse);
    } catch (e) {
      await fetchCart(tokenToUse);
    }
  }

  // Change item quantity or remove if zero
  Future<void> updateQuantity(String cartItemId, int quantity, {String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId, token: tokenToUse);
      } else {
        await _apiService.updateCartItem(cartItemId, quantity, tokenToUse);
        
        await fetchCart(tokenToUse);
      }
    } catch (e) {
      await fetchCart(tokenToUse);
    }
  }

  // Increment Quantity
  Future<void> incrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) {
      await updateQuantity(item.id!, item.quantity + 1, token: token);
    }
  }

  // Decrement Quantity
  Future<void> decrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) {
      if (item.quantity > 1) {
        await updateQuantity(item.id!, item.quantity - 1, token: token);
      } else {
        await removeFromCart(item.id!, token: token);
      }
    }
  }

  // Wipe all items from the cart
  Future<void> clearCart({String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;

    try {
      _items.clear();
      notifyListeners();

      await _apiService.clearCart(tokenToUse);
      
      await fetchCart(tokenToUse);
    } catch (e) {
      await fetchCart(tokenToUse);
    }
  }

  // Reset After Order
  Future<void> resetAfterOrder({String? token}) async {
    _items.clear();
    notifyListeners();
    
    final tokenToUse = token ?? _token;
    if (tokenToUse != null) {
      await fetchCart(tokenToUse);
    }
  }

  // Is In Cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get Quantity
  int getQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
