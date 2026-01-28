// ============================================================================
// ORDERS PROVIDER - Order History State Management
// ============================================================================
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrdersProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders.reversed);

  int get count => _orders.length;

  bool get isEmpty => _orders.isEmpty;

  // Get order by ID
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  // Place new order
  Future<bool> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double shipping,
    String? shippingAddress,
  }) async {
    try {
      final order = Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        items: items,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: subtotal + tax + shipping,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      _orders.add(order);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update order status
  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = _orders[index].copyWith(status: OrderStatus.cancelled);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get orders by status
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // Load orders (from API/database)
  Future<void> loadOrders(String userId) async {
    // TODO: Implement actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }
}
