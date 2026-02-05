import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// shopping cart state manager
class CartProvider with ChangeNotifier {
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

  // refreshes token and items
  void updateToken(String? newToken) {
    if (newToken != _token) {
      _token = newToken;
      _items.clear();
      if (newToken != null) fetchCart(newToken);
      notifyListeners();
    }
  }

  // gets current cart from server
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
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // adds product to cart
  Future<void> addToCart(Product product, {int quantity = 1, String? size, double? price, String? token}) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return;
    try {
      await _apiService.addToCart(product.id, quantity, tokenToUse, size: size);
      await fetchCart(tokenToUse);
    } catch (_) {}
  }

  // removes item from cart
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

  // sets item quantity
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

  // increases quantity by 1
  Future<void> incrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) await updateQuantity(item.id!, item.quantity + 1, token: token);
  }

  // decreases quantity by 1
  Future<void> decrementQuantity(CartItem item, {String? token}) async {
    if (item.id != null) {
      if (item.quantity > 1) {
        await updateQuantity(item.id!, item.quantity - 1, token: token);
      } else {
        await removeFromCart(item.id!, token: token);
      }
    }
  }

  // empties the cart
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

  // cleanup after successful order
  Future<void> resetAfterOrder({String? token}) async {
    _items.clear();
    notifyListeners();
    final tokenToUse = token ?? _token;
    if (tokenToUse != null) await fetchCart(tokenToUse);
  }

  // checks if product is in cart
  bool isInCart(String productId) => _items.any((item) => item.product.id == productId);

  // retrieves quantity of a product
  int getQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }
}
