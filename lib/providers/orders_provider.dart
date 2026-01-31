// Imports
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';

// Orders Provider
class OrdersProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Order> _orders = [];
  String? _token;

  List<Order> get orders => List.unmodifiable(_orders);
  int get count => _orders.length;
  bool get isEmpty => _orders.isEmpty;

  void updateToken(String? newToken, String? userId) {
    if (newToken != _token) {
      _token = newToken;
      _orders.clear();
      if (newToken != null && userId != null) {
        loadOrders(userId, newToken);
      }
      notifyListeners();
    }
  }

  // Get Order By Id
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  // Place Order
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
        'items': items.map((i) => {
          'product_id': i.product.id,
          'product_name': i.product.title,
          'product_image': i.product.imageUrl,
          'quantity': i.quantity,
          'price': i.product.price,
        }).toList(),
        'total_price': totalPrice,
        'shipping_address': shippingAddress ?? 'No address provided',
        'payment_status': paymentStatus,
      };

      final response = await _apiService.placeOrder(orderData, tokenToUse);
      
      final order = Order(
        id: (response['order']['id'] ?? 'ORD-${DateTime.now().millisecondsSinceEpoch}').toString(),
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: totalPrice,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      _orders.insert(0, order);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update Order Status
  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }

  // Cancel Order
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
      return false;
    }
  }

  // Update Payment Status
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
      return false;
    }
  }

  // Get Orders By Status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Load Orders
  Future<void> loadOrders(String userId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> data = await _apiService.fetchOrders(token);
      _orders.clear();
      
      for (var item in data) {
         final List<dynamic> apiItems = item['items'] ?? [];
         final List<CartItem> orderItems = apiItems.map((apiItem) {
           return CartItem(
             product: Product.fromJson(apiItem['product']),
             quantity: apiItem['quantity'] ?? 1,
           );
         }).toList();

         final totalPrice = _parseNum(item['total_price']);
         final subtotal = _parseNum(item['subtotal']) > 0 
                         ? _parseNum(item['subtotal']) 
                         : totalPrice * 0.8;
         final tax = _parseNum(item['tax']) > 0 
                    ? _parseNum(item['tax']) 
                    : totalPrice * 0.1;
         final shipping = _parseNum(item['shipping']) > 0 
                         ? _parseNum(item['shipping']) 
                         : totalPrice * 0.1;

         _orders.add(Order(
           id: item['id'].toString(),
           userId: item['user_id'].toString(),
           items: orderItems,
           subtotal: subtotal,
           tax: tax,
           shipping: shipping,
           total: totalPrice,
           status: _parseOrderStatus(item['status'], item['payment_status']),
           orderDate: DateTime.parse(item['created_at'] ?? DateTime.now().toString()),
           shippingAddress: item['shipping_address'],
         ));
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Parse Num
  double _parseNum(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // Parse Order Status
  OrderStatus _parseOrderStatus(String? status, String? paymentStatus) {
    switch (status?.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'paid': return OrderStatus.paid;
      case 'processing': return OrderStatus.processing;
      case 'shipped': return OrderStatus.shipped;
      case 'delivered': return OrderStatus.delivered;
      case 'cancelled': return OrderStatus.cancelled;
      case 'declined': return OrderStatus.declined;
    }

    final pStatus = paymentStatus?.toLowerCase();
    if (pStatus == 'declined' || pStatus == 'failed') {
      return OrderStatus.declined;
    }
    
    return OrderStatus.pending;
  }
}
