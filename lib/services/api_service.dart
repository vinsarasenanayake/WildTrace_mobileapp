import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:quickalert/quickalert.dart';
import '../models/product.dart';

// central service for api communications
class ApiService {
  static String get baseHost => 'https://wildtrace-production.up.railway.app';
  static const String _apiPath = '/api';
  static const String _storagePath = '/storage/';
  static const String _rootPath = '/';

  static String get baseUrl => '$baseHost$_apiPath';
  static String get storageUrl => '$baseHost$_storagePath';
  static String get baseHostUrl => '$baseHost$_rootPath';

  // handles image path resolution
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('storage/')) return '$baseHost/$cleanPath';
    return '$baseHostUrl$cleanPath';
  }

  List<Product> _parseProductList(dynamic data) {
    final List<dynamic> list = (data is Map && data.containsKey('data')) ? data['data'] : (data is List ? data : []);
    return list.map((item) {
      if (item['image_url'] != null) {
        item['image_url'] = resolveImageUrl(item['image_url'].toString());
      }
      if (item['photographer'] != null && item['photographer']['image'] != null) {
        item['photographer']['image'] = resolveImageUrl(item['photographer']['image'].toString());
      }
      return Product.fromJson(item);
    }).toList();
  }

  // retrieves product catalog
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
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // fetches variant-specific pricing
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

  // retrieves single product metadata
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
          data['image_url'] = resolveImageUrl(data['image_url'].toString());
        }
        if (data['photographer'] != null && data['photographer']['image'] != null) {
          data['photographer']['image'] = resolveImageUrl(data['photographer']['image'].toString());
        }
        return Product.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

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

  // handles user authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['user'] != null) {
          final userData = decoded['user'];
          final bool isAdmin = userData['role']?.toString().toLowerCase() == 'admin' || 
                             userData['role_id']?.toString() == '1' || 
                             userData['is_admin'] == true || 
                             userData['is_admin']?.toString() == '1';
          if (isAdmin) throw Exception('Admin dashboard access restricted to web platform.');
        }
        return decoded;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Incorrect email or password.');
      }
    } catch (e) {
      if (e is http.ClientException || e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Ensure backend is running.');
      }
      rethrow;
    }
  }

  // processes account registration
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

  Future<void> logout(String token) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // submits new order transaction
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

  // fetches historical orders
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
               item['product_image'] = resolveImageUrl(item['product_image'].toString());
               if (item['product'] == null) item['product'] = {};
               item['product']['image_url'] = item['product_image'];
            } 
            else if (item['product'] != null && item['product']['image_url'] != null) {
              item['product']['image_url'] = resolveImageUrl(item['product']['image_url'].toString());
            }
          }
        }
      }
      return orders;
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> cancelOrder(String orderId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders/$orderId/cancel'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel order');
    }
  }

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
      throw Exception('Failed to update payment status');
    }
  }

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
          productData['image_url'] = resolveImageUrl(productData['image_url'].toString());
        }
        return Product.fromJson(productData);
      }).toList();
    } else {
      throw Exception('Failed to load favorites');
    }
  }

  // toggles product favorite state
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

  // retrieves active shopping cart
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
          item['product']['image_url'] = resolveImageUrl(item['product']['image_url'].toString());
        }
      }
      return items;
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // adds item to persistent cart
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
      throw Exception('Failed to add to cart');
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'quantity': quantity}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart');
    }
  }

  Future<void> removeFromCart(String cartItemId, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartItemId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart');
    }
  }

  // clears user cart remotely
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

  // fetches platform content data
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
          item['image_url'] = resolveImageUrl(item['image_url'].toString());
        } else if (item['image'] != null) {
           item['image'] = resolveImageUrl(item['image'].toString());
        }
      }
      return list;
    } else {
      throw Exception('Failed to load photographers');
    }
  }

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
}

// manages stripe payment processing
class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();
  final String _secretKey = dotenv.get('STRIPE_SECRET_KEY');

  // executes payment intent workflow
  Future<void> makePayment({
    required double amount,
    required String currency,
    required BuildContext context,
    required Function() onSuccess,
  }) async {
    try {
      Map<String, dynamic>? paymentIntentData = await _createPaymentIntent(
        (amount * 100).toInt().toString(),
        currency,
      );

      if (paymentIntentData == null || paymentIntentData['client_secret'] == null) {
        throw Exception('Failed to create Payment Intent');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Wild Trace',
        ),
      );

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

  // triggers stripe payment sheet
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
    } catch (_) {}
  }

  // creates remote payment intent
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
