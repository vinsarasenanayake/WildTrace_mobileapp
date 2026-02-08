import 'base_api_service.dart';
import '../../models/product.dart';

// product api service
class ProductApiService extends BaseApiService {
  Future<List<Product>> fetchProducts({String? token}) async {
    final data = await get('/products', token: token);
    return _parseProductList(data);
  }

  Future<Product?> fetchProductDetails(String productId, {String? token}) async {
    final data = await get('/products/$productId', token: token);
    if (data != null) {
      return Product.fromJson(data);
    }
    return null;
  }

  Future<double?> getProductPrice(String productId, String size, {String? token}) async {
    final data = await get('/products/$productId/price?size=${Uri.encodeComponent(size)}', token: token);
    return (data['price'] != null) ? (num.tryParse(data['price'].toString())?.toDouble()) : null;
  }

  List<Product> _parseProductList(dynamic data) {
    final List<dynamic> list = (data is Map && data.containsKey('data')) ? data['data'] : (data is List ? data : []);
    
    final products = <Product>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          products.add(Product.fromJson(item));
        } catch (e) {
          // skip errors
        }
      }
    }
    return products;
  }
}
