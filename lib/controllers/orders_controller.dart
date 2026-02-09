import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

class OrdersController with ChangeNotifier {
  // controller to manage orders with api and local db
  final OrderApiService _apiService = OrderApiService();
  final DatabaseService _dbService = DatabaseService();
  final List<Order> _orders = [];
  String? _token;
  bool _isLoading = false;

  List<Order> get orders => List.unmodifiable(_orders);
  int get count => _orders.length;
  bool get isEmpty => _orders.isEmpty;
  bool get isLoading => _isLoading;

  // Update session token and load user order history
  void updateToken(String? newToken, String? userId) {
    // update token when user log in or out, and get orders data if logged in
    if (newToken != _token) {
      _token = newToken;
      _orders.clear();
      if (newToken != null && userId != null) loadOrders(userId, newToken);
      notifyListeners();
    }
  }

  // Find a specific order from the local list
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // Create a new order by sending items and details to backend
  Future<bool> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double shipping,
    String? token,
    String? shippingAddress,
    String paymentStatus = 'pending',
  }) async {
    final tokenToUse = token ?? _token;
    if (tokenToUse == null) return false;
    try {
      final totalPrice = subtotal + tax + shipping;
      final Map<String, dynamic> orderData = {
        'items': items
            .map(
              (i) => {
                'product_id': i.product.id,
                'product_name': i.product.title,
                'product_image': i.product.imageUrl,
                'quantity': i.quantity,
                'price': i.product.price,
              },
            )
            .toList(),
        'total_price': totalPrice,
        'shipping_address': shippingAddress ?? 'No address provided',
        'payment_status': paymentStatus,
      };
      // send order to backend
      final response = await _apiService.placeOrder(orderData, tokenToUse);
      final orderDate = DateTime.now();

      final order = Order(
        id:
            (response['order']['id'] ??
                    'ORD-${DateTime.now().millisecondsSinceEpoch}')
                .toString(),
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: totalPrice,
        status: paymentStatus == 'paid'
            ? OrderStatus.paid
            : OrderStatus.pending,
        orderDate: orderDate,
        estimatedDeliveryDate: orderDate.add(const Duration(days: 3)),
        shippingAddress: shippingAddress,
      );
      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Place Order Error: $e');
      return false;
    }
  }

  // Request order cancellation from backend
  Future<bool> cancelOrder(String orderId) async {
    if (_token == null) return false;
    try {
      await _apiService.cancelOrder(orderId, _token!);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(status: OrderStatus.declined);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Cancel Order Error: $e');
      return false;
    }
  }

  // Notify backend of updated payment state
  Future<bool> updatePaymentStatus(String orderId, String status) async {
    if (_token == null) return false;
    try {
      await _apiService.updateOrderPaymentStatus(orderId, status, _token!);
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(
          status: status == 'paid' ? OrderStatus.paid : _orders[index].status,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update Payment Error: $e');
      return false;
    }
  }

  // Fetch all orders for current user and update cache
  Future<void> loadOrders(String userId, String token) async {
    _isLoading = true;
    notifyListeners();

    // try loading from cache
    try {
      final cached = await _dbService.getCachedOrders(userId);
      if (cached.isNotEmpty) {
        _orders.clear();
        _orders.addAll(cached);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Order Cache Load Error: $e');
    }

    try {
      // get orders data from backend
      final List<dynamic> data = await _apiService.fetchOrders(token);
      _orders.clear();
      for (var item in data) {
        final apiItems = item['items'] as List<dynamic>? ?? [];
        final List<CartItem> orderItems = apiItems.map((apiItem) {
          return CartItem(
            product: Product.fromJson(apiItem['product']),
            quantity: apiItem['quantity'] ?? 1,
          );
        }).toList();

        final totalPrice = _parseNum(item['total_price']);
        final subtotal = _parseNum(item['subtotal']);
        final tax = _parseNum(item['tax']);
        final shipping = _parseNum(item['shipping']);

        final orderDate = DateTime.parse(
          item['created_at'] ?? DateTime.now().toString(),
        );

        _orders.add(
          Order(
            id: item['id'].toString(),
            userId: item['user_id'].toString(),
            items: orderItems,
            subtotal: subtotal,
            tax: tax,
            shipping: shipping,
            total: totalPrice,
            status: _parseOrderStatus(item['status'], item['payment_status']),
            orderDate: orderDate,
            estimatedDeliveryDate: item['estimated_delivery_date'] != null
                ? DateTime.parse(item['estimated_delivery_date'])
                : orderDate.add(const Duration(days: 3)),
            shippingAddress: item['shipping_address'],
          ),
        );
      }
      // update cache
      await _dbService.cacheOrders(_orders);
    } catch (e) {
      debugPrint('Load Orders Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //convert dynamic value to double safely
  double _parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // determine order status based on backend status and payment status
  OrderStatus _parseOrderStatus(String? status, String? paymentStatus) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'paid':
        return OrderStatus.paid;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'declined':
        return OrderStatus.declined;
    }
    final pStatus = paymentStatus?.toLowerCase();
    if (pStatus == 'declined' || pStatus == 'failed') {
      return OrderStatus.declined;
    }
    return OrderStatus.pending;
  }
}
