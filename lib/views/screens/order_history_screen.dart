import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/cards/order_card.dart';
import '../widgets/cards/order_item_card.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import 'package:quickalert/quickalert.dart';

// purchase history records
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // initiates orders retrieval on component mount
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  // synchronizes local order list with backend records
  Future<void> _refreshOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    // requires authenticated session context
    if (authProvider.token != null && authProvider.currentUser?.id != null) {
      await ordersProvider.loadOrders(authProvider.currentUser!.id, authProvider.token!);
    }
  }

  // manages the payment fulfillment workflow via Stripe
  Future<void> _payWithStripe(Order order) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    
    // triggers external payment gateway
    await StripeService.instance.makePayment(
      amount: order.total,
      currency: 'USD',
      context: context,
      onSuccess: () async {
        // synchronizes payment state with platform backend
        final success = await ordersProvider.updatePaymentStatus(order.id, 'paid');
        if (mounted) {
          final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
          if (success) {
            // provides delivery expectations to the user
            final estimatedDate = DateTime.now().add(const Duration(days: 3));
            final formattedDate = DateFormat('MMMM dd, yyyy').format(estimatedDate);

            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Payment Successful',
              text: 'Order is now being processed! \nEstimated Delivery: $formattedDate',
              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              titleColor: isDarkMode ? Colors.white : Colors.black,
              textColor: isDarkMode ? Colors.white70 : Colors.black87,
              confirmBtnText: 'OKAY',
              confirmBtnTextStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            );
          } else {
            // handles backend synchronization failures post-payment
             QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Processing Error',
              text: 'Payment recorded by Stripe, but backend update failed. Please contact support.',
              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              titleColor: isDarkMode ? Colors.white : Colors.black,
              textColor: isDarkMode ? Colors.white70 : Colors.black87,
            );
          }
        }
      },
    );
  }

  // builds the visual purchase history workflow
  @override
  Widget build(BuildContext context) {
    // theme and layout design tokens
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
        // session exit navigation
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
      // dynamic update binding for order records
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          final orders = ordersProvider.orders;
          
          // loading visualization for asynchronous data
          if (ordersProvider.isLoading && orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF27AE60)));
          }

          // handles scenarios where no purchases exist
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
                  // guides user back to core value proposition
                  SizedBox(
                    width: 220,
                    child: CustomButton(
                      text: 'EXPLORE GALLERY',
                      type: CustomButtonType.secondary,
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(1);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          
          // manages manual list synchronization
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            color: const Color(0xFF27AE60),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                
                // singular order presentation card
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: OrderCard(
                    status: _statusToString(order.status),
                    orderId: 'ORDER #${order.id}',
                    date: DateFormat('MMMM d, y').format(order.orderDate),
                    total: '\$${order.total.toStringAsFixed(2)}',
                    estimatedDelivery: order.estimatedDeliveryDate != null 
                        ? DateFormat('MMMM d, y').format(order.estimatedDeliveryDate!) 
                        : null,
                    onPayNow: () => _payWithStripe(order),
                    onCancel: () async {
                      // validates that order can still be aborted
                      if (order.status == OrderStatus.pending) {
                        final success = await ordersProvider.cancelOrder(order.id);
                        if (context.mounted) {
                          final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                          if (success) {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              title: 'Order Cancelled',
                              text: 'Order cancelled successfully',
                              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                              titleColor: isDarkMode ? Colors.white : Colors.black,
                              textColor: isDarkMode ? Colors.white70 : Colors.black87,
                            );
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.error,
                              title: 'Cancellation Failed',
                              text: 'Failed to cancel order',
                              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                              titleColor: isDarkMode ? Colors.white : Colors.black,
                              textColor: isDarkMode ? Colors.white70 : Colors.black87,
                            );
                          }
                        }
                      } else {
                        // feedback for immutable order states
                        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.warning,
                          title: 'Action Denied',
                          text: 'Cannot cancel this order',
                          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          titleColor: isDarkMode ? Colors.white : Colors.black,
                          textColor: isDarkMode ? Colors.white70 : Colors.black87,
                        );
                      }
                    },
                    // transforms internal line items for presentation
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
  
  // transforms enum state to human readable identifier
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

