import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api/index.dart';
import '../services/database/database_service.dart';

class SyncController with ChangeNotifier {
  // controller to manage syncing pending actions with the backend when online again
  final CartApiService _cartApiService = CartApiService();
  final DatabaseService _dbService = DatabaseService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // sync pending actions to backend
  // Process queued offline actions and synchronize with backend
  Future<void> syncPendingActions(String token) async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();

    try {
      final pending = await _dbService.getPendingActions();
      if (pending.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return;
      }

      for (var action in pending) {
        final id = action['id'];
        final type = action['action_type'];
        final data = jsonDecode(action['data']);

        try {
          if (type == 'cart_add') {
            await _cartApiService.addToCart(
              data['product_id'],
              data['quantity'],
              token,
              size: data['size'],
            );
          } else if (type == 'cart_remove') {
            await _cartApiService.removeFromCart(data['id'], token);
          } else if (type == 'cart_update') {
            await _cartApiService.updateCartItem(
              data['id'],
              data['quantity'],
              token,
            );
          } else if (type == 'favorite_toggle') {
            await _cartApiService.toggleFavorite(data['id'], token);
          }

          // if successful, remove from pending
          await _dbService.deletePendingAction(id);
        } catch (e) {
          debugPrint('Sync individual action error: $e');

          if (e.toString().contains('SocketException') ||
              e.toString().contains('TimeoutException')) {
            break;
          } else {
            await _dbService.deletePendingAction(id);
          }
        }
      }
    } catch (e) {
      debugPrint('Global Sync Error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
