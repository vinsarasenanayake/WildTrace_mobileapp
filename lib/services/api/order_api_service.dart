import 'base_api_service.dart';

class OrderApiService extends BaseApiService {
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> orderData, String token) async {
    return await post('/orders', body: orderData, token: token);
  }

  Future<List<dynamic>> fetchOrders(String token) async {
    final data = await get('/orders', token: token);
    return _parseOrderList(data);
  }

  Future<void> cancelOrder(String orderId, String token) async {
    await post('/orders/$orderId/cancel', token: token);
  }

  Future<void> updateOrderPaymentStatus(String orderId, String status, String token) async {
    await post('/orders/$orderId/payment-status', body: {'payment_status': status}, token: token);
  }

  List<dynamic> _parseOrderList(dynamic data) {
    return _responseToList(data);
  }

  List<dynamic> _responseToList(dynamic decoded) {
    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'];
    } else if (decoded is List) {
      return decoded;
    }
    return [];
  }
}
