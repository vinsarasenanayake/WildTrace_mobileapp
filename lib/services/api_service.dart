// Imports
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quickalert/quickalert.dart';
import '../models/product.dart';
import '../models/photographer.dart';
import '../models/milestone.dart';

// Api Service
class ApiService {
  // Base Host
  static String get baseHost {
    return 'https://wildtrace-production.up.railway.app';
  }

  // Paths
  static const String _apiPath = '/api';
  static const String _storagePath = '/storage/';
  static const String _rootPath = '/';

  // Configurations
  static String get baseUrl => '$baseHost$_apiPath';
  static String get storageUrl => '$baseHost$_storagePath';
  static String get baseHostUrl => '$baseHost$_rootPath';

  // Image Url Helper
  String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    
    String resolvedPath = path;
    if (resolvedPath.startsWith('http')) {
      return resolvedPath;
    }
    
    String cleanPath = resolvedPath.startsWith('/') ? resolvedPath.substring(1) : resolvedPath;
    
    if (cleanPath.startsWith('assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/', '');
    }

    if (cleanPath.startsWith('storage/')) {
      return '$baseHost/$cleanPath';
    }

    return '$baseHostUrl$cleanPath';
  }

  // Parse Products
  List<Product> _parseProductList(dynamic data) {
    final List<dynamic> list = (data is Map && data.containsKey('data')) ? data['data'] : (data is List ? data : []);
    
    return list.map((item) {
      if (item['image_url'] != null) {
        item['image_url'] = _resolveImageUrl(item['image_url'].toString());
      }
      if (item['photographer'] != null && item['photographer']['image'] != null) {
        item['photographer']['image'] = _resolveImageUrl(item['photographer']['image'].toString());
      }
      return Product.fromJson(item);
    }).toList();
  }

  // Fetch Products
  Future<List<Product>> fetchProducts({String? token}) async {
    final url = Uri.parse('$baseUrl/products');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parseProductList(json.decode(response.body));
      } else if (response.statusCode == 401) {
        return [];
      } else {
        throw Exception('Failed to load products (Status: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get Product Price
  Future<double?> getProductPrice(String productId, String size, {String? token}) async {
    final url = Uri.parse('$baseUrl/products/$productId/price?size=${Uri.encodeComponent(size)}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['price'] != null) ? (num.tryParse(data['price'].toString())?.toDouble()) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch Product Details
  Future<Product?> fetchProductDetails(String productId, {String? token}) async {
    final url = Uri.parse('$baseUrl/products/$productId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['image_url'] != null) {
          data['image_url'] = _resolveImageUrl(data['image_url'].toString());
        }
        if (data['photographer'] != null && data['photographer']['image'] != null) {
          data['photographer']['image'] = _resolveImageUrl(data['photographer']['image'].toString());
        }
        
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // User Profile
  // Fetch User Profile
  Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded['image'] != null) {
        decoded['image'] = _resolveImageUrl(decoded['image'].toString());
      } else if (decoded['profile_photo_url'] != null) {
        decoded['profile_photo_url'] = _resolveImageUrl(decoded['profile_photo_url'].toString());
      }
      return decoded;
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  // Update User Profile
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(profileData),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update profile');
    }
  }

  // Authentication
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': normalizedEmail,
          'password': normalizedPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseBody = response.body;
      
      if (response.statusCode == 200) {
        if (responseBody.isEmpty) throw Exception('Server returned an empty response');
        final decoded = json.decode(responseBody);
        
        if (decoded['user'] != null && decoded['user']['image'] != null) {
          decoded['user']['image'] = _resolveImageUrl(decoded['user']['image'].toString());
        }
        
        return decoded;
      } else {
        String errorMessage = 'Invalid credentials';
        try {
          if (responseBody.isNotEmpty) {
            final error = json.decode(responseBody);
            errorMessage = error['message'] ?? 'Status ${response.statusCode}';
          } else {
            errorMessage = 'Server error (${response.statusCode})';
          }
        } catch (_) {
          errorMessage = 'Server error (${response.statusCode})';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Ensure Laravel is running at $baseUrl');
      }
      rethrow;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(userData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to register');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
    }
  }

  // Orders
  // Place Order
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(orderData),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to place order');
    }
  }

  // Fetch Orders
  Future<List<dynamic>> fetchOrders(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> orders = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : []);
      
      for (var order in orders) {
        if (order['items'] != null) {
          for (var item in order['items']) {
            if (item['product_image'] != null && item['product_image'].toString().isNotEmpty) {
               item['product_image'] = _resolveImageUrl(item['product_image'].toString());
               if (item['product'] == null) item['product'] = {};
               item['product']['image_url'] = item['product_image'];
            } 
            else if (item['product'] != null && item['product']['image_url'] != null) {
              item['product']['image_url'] = _resolveImageUrl(item['product']['image_url'].toString());
            }
          }
        }
      }
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // Cancel Order
  Future<void> cancelOrder(String orderId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/cancel'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to cancel order');
      } catch (_) {
        throw Exception('Failed to cancel order');
      }
    }
  }

  // Update Order Payment Status
  Future<void> updateOrderPaymentStatus(String orderId, String status, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/payment-status'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'payment_status': status}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      try {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to update payment status');
      } catch (_) {
        throw Exception('Failed to update payment status');
      }
    }
  }

  // Favorites
  // Fetch Favorites
  Future<List<Product>> fetchFavorites(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : []);
      
      return list.map((item) {
        final productData = item['product'] ?? item;
        if (productData['image_url'] != null) {
          productData['image_url'] = _resolveImageUrl(productData['image_url'].toString());
        }
        return Product.fromJson(productData);
      }).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  // Toggle Favorite
  Future<Map<String, dynamic>> toggleFavorite(String productId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/favorites/toggle'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'product_id': productId}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to toggle favorite');
    }
  }

  // Check Favorite
  Future<bool> checkFavorite(String productId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/favorites/check/$productId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Cart
  // Fetch Cart
  Future<List<dynamic>> fetchCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> items = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : []);
      
      for (var item in items) {
        if (item['product'] != null && item['product']['image_url'] != null) {
          item['product']['image_url'] = _resolveImageUrl(item['product']['image_url'].toString());
        }
      }
      return items;
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // Add to Cart
  Future<Map<String, dynamic>> addToCart(String productId, int quantity, String token, {String? size}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
        'size': size,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to add to cart');
    }
  }

  // Update Cart Item
  Future<Map<String, dynamic>> updateCartItem(String cartItemId, int quantity, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'quantity': quantity}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update cart');
    }
  }

  // Remove from Cart
  Future<void> removeFromCart(String cartItemId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to remove from cart');
    }
  }

  // Clear Cart
  Future<void> clearCart(String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }

  // Fetch Photographers
  Future<List<dynamic>> fetchPhotographers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/photographers'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> list = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : []);
      
      for (var item in list) {
        if (item['image_url'] != null) {
          item['image_url'] = _resolveImageUrl(item['image_url'].toString());
        } else if (item['image'] != null) {
           item['image'] = _resolveImageUrl(item['image'].toString());
        }
      }
      return list;
    } else {
      throw Exception('Failed to load photographers');
    }
  }

  // Fetch Milestones
  Future<List<dynamic>> fetchMilestones() async {
    final response = await http.get(
      Uri.parse('$baseUrl/milestones'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : []);
    } else {
      throw Exception('Failed to load milestones');
    }
  }

  // Sync Cart
  Future<void> syncCart(List<Map<String, dynamic>> cartData, String token) async {
    await http.post(
      Uri.parse('$baseUrl/cart/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'items': cartData}),
    ).timeout(const Duration(seconds: 10));
  }
}

// Stripe Service
class StripeService {
  // Initialization
  StripeService._();

  static final StripeService instance = StripeService._();

  final String _secretKey = dotenv.get('STRIPE_SECRET_KEY');

  Future<void> makePayment({
    required double amount,
    required String currency,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      // Create Payment Intent
      Map<String, dynamic>? paymentIntentData = await _createPaymentIntent(
        (amount * 100).toInt().toString(),
        currency,
      );

      if (paymentIntentData == null || paymentIntentData['client_secret'] == null) {
        throw Exception('Failed to create Payment Intent: ${paymentIntentData?['error']?['message'] ?? 'Unknown Error'}');
      }

      // Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Wild Trace',
        ),
      );

      // Display Payment Sheet
      await _displayPaymentSheet(onSuccess, context);
    } catch (e) {

      if (context.mounted) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Payment Error',
          text: e.toString(),
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          titleColor: isDarkMode ? Colors.white : Colors.black,
          textColor: isDarkMode ? Colors.white70 : Colors.black87,
        );
      }
    }
  }

  Future<void> _displayPaymentSheet(Function() onSuccess, BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      onSuccess();
    } on StripeException catch (e) {

      if (context.mounted) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Cancelled',
          text: 'Payment Cancelled',
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          titleColor: isDarkMode ? Colors.white : Colors.black,
          textColor: isDarkMode ? Colors.white70 : Colors.black87,
        );
      }
    } catch (e) {

    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      
      return jsonDecode(response.body);
    } catch (err) {

      rethrow;
    }
  }
}
