import 'base_api_service.dart';
import '../../models/product.dart';

class CartApiService extends BaseApiService {
  // Fetch cart items from backend
  Future<List<dynamic>> fetchCart(String token) async {
    final data = await get('/cart', token: token);
    return _parseList(data);
  }

  Future<Map<String, dynamic>> addToCart(String productId, int quantity, String token, {String? size}) async {
    return await post('/cart', body: {
      'product_id': productId,
      'quantity': quantity,
      'size': size,
    }, token: token);
  }

  Future<void> updateCartItem(String cartItemId, int quantity, String token) async {
    await put('/cart/$cartItemId', body: {'quantity': quantity}, token: token);
  }

  Future<void> removeFromCart(String cartItemId, String token) async {
    await delete('/cart/$cartItemId', token: token);
  }

  Future<void> clearCart(String token) async {
    await delete('/cart', token: token);
  }

  Future<List<Product>> fetchFavorites(String token) async {
     final data = await get('/favorites', token: token);
     return _parseProductList(data);
  }

  // Toggle favorite status for a product
  Future<Map<String, dynamic>> toggleFavorite(String productId, String token) async {
     return await post('/favorites/toggle', body: {'product_id': productId}, token: token);
  }

  List<dynamic> _parseList(dynamic decoded) {
    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'];
    } else if (decoded is List) {
      return decoded;
    }
    return [];
  }

  List<Product> _parseProductList(dynamic data) {
    final list = _parseList(data);
    return list.map((item) {
      final productData = item['product'] ?? item;
      return Product.fromJson(productData);
    }).toList();
  }
}
