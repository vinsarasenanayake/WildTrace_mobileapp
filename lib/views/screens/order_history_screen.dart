import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/orders_controller.dart';
import '../../models/order.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/cards/card_widgets.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../utilities/alert_service.dart';
import 'checkout_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // Initialize state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  // Fetch latest orders from api
  Future<void> _refreshOrders() async {
    final authProvider = Provider.of<AuthController>(context, listen: false);
    final ordersProvider = Provider.of<OrdersController>(context, listen: false);
    if (authProvider.token != null && authProvider.currentUser?.id != null) {
      await ordersProvider.loadOrders(authProvider.currentUser!.id, authProvider.token!);
    }
  }


  // Build ui for order history screen
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? Colors.black : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF9FBF9),
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
      body: Consumer<OrdersController>(
        builder: (context, ordersProvider, child) {
          final orders = ordersProvider.orders;
          
          if (ordersProvider.isLoading && orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)));
          }

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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 220,
                    child: CustomButton(
                      text: 'EXPLORE GALLERY',
                      type: CustomButtonType.secondary,
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Provider.of<NavigationController>(context, listen: false).setSelectedIndex(1);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            color: const Color(0xFF27AE60),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: OrderCard(
                    status: _statusToString(order.status),
                    orderId: 'ORDER #${order.id}',
                    date: DateFormat('MMMM d, y').format(order.orderDate),
                    total: '\$${order.total.toStringAsFixed(2)}',
                    estimatedDelivery: (order.status == OrderStatus.pending) 
                        ? null 
                        : (order.estimatedDeliveryDate != null 
                            ? DateFormat('MMMM d, y').format(order.estimatedDeliveryDate!) 
                            : null),
                    onPayNow: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckoutScreen(pendingOrder: order)),
                      );
                    },
                    onCancel: () async {
                      if (order.status == OrderStatus.pending) {
                         AlertService.showConfirmation(
                            context: context,
                            title: 'Cancel Order',
                            text: 'Are you sure you want to cancel this order?',
                            confirmBtnText: 'Yes, Cancel',
                            cancelBtnText: 'No',
                            onConfirm: () async {
                                Navigator.pop(context); 
                                final success = await ordersProvider.cancelOrder(order.id);
                                if (context.mounted) {
                                  if (success) {
                                    AlertService.showSuccess(
                                      context: context,
                                      title: 'Order Cancelled',
                                      text: 'Order cancelled successfully',
                                    );
                                  } else {
                                    AlertService.showError(
                                      context: context,
                                      title: 'Cancellation Failed',
                                      text: 'Failed to cancel order',
                                    );
                                  }
                                }
                            },
                            onCancel: () => Navigator.pop(context),
                         );
                      } else {
                        AlertService.showWarning(
                          context: context,
                          title: 'Action Denied',
                          text: 'Cannot cancel this order',
                        );
                      }
                    },
                    items: order.items.map((item) => OrderItem(
                      image: item.product.imageUrl,
                      title: item.product.title,
                      subtitle: item.size ?? item.product.category,
                      quantity: item.quantity,
                      price: item.price ?? item.product.price,
                    )).toList(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  // Convert order status enum to string
  String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'PENDING';
      case OrderStatus.paid: return 'PAID';
      case OrderStatus.processing: return 'PROCESSING';
      case OrderStatus.shipped: return 'SHIPPED';
      case OrderStatus.delivered: return 'DELIVERED';
      case OrderStatus.cancelled: return 'CANCELLED';
      case OrderStatus.declined: return 'DECLINED';
    }
  }
}
