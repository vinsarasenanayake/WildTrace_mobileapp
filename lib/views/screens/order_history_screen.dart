// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/cards/order_card.dart';

// ============================================================================
// ORDER HISTORY SCREEN
// ============================================================================
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: textColor,
          ),
        ),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          final orders = ordersProvider.orders;
          
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                   const SizedBox(height: 16),
                   Text(
                    'No orders yet', 
                    style: GoogleFonts.inter(
                      fontSize: 14, 
                      color: Colors.grey.shade500, 
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              // Show orders in reverse chronological order (newest first)
              final order = orders[orders.length - 1 - index];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: OrderCard(
                  status: _statusToString(order.status),
                  orderId: 'ORDER #${order.id}',
                  date: DateFormat('MMMM d, y').format(order.orderDate),
                  total: '\$${order.total.toStringAsFixed(2)}',
                  onPayNow: () {
                    // Implement pay now logic for pending orders
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment functionality coming soon'))
                    );
                  },
                  onCancel: () {
                    if (order.status == OrderStatus.pending) {
                      ordersProvider.updateOrderStatus(order.id, OrderStatus.cancelled);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order cancelled'))
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot cancel this order'))
                      );
                    }
                  },
                  items: order.items.map((item) => OrderItem(
                    image: item.product.imageUrl,
                    title: item.product.title,
                    subtitle: item.product.category,
                    quantity: item.quantity,
                    price: item.product.price,
                  )).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'PENDING';
      case OrderStatus.processing: return 'PROCESSING';
      case OrderStatus.shipped: return 'SHIPPED';
      case OrderStatus.delivered: return 'DELIVERED';
      case OrderStatus.cancelled: return 'CANCELLED';
    }
  }
}

// --- Widgets ---




