// Imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/cards/order_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';

// Order History Screen
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrders();
    });
  }

  Future<void> _refreshOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    if (authProvider.token != null && authProvider.currentUser?.id != null) {
      await ordersProvider.loadOrders(authProvider.currentUser!.id, authProvider.token!);
    }
  }

  Future<void> _launchPaymentUrl(String orderId) async {
    final String baseUrl = ApiService.baseHostUrl; 
    final String urlString = '${baseUrl}order/$orderId/repay';
    
    final Uri url = Uri.parse(urlString);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch payment page: $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error launching URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching payment page')),
        );
      }
    }
  }

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
          
          if (ordersProvider.isLoading && orders.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
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
                        Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(1);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            color: const Color(0xFF2ECC71),
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
                    onPayNow: () => _launchPaymentUrl(order.id),
                    onCancel: () async {
                      if (order.status == OrderStatus.pending) {
                        final success = await ordersProvider.cancelOrder(order.id);
                        if (context.mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order cancelled successfully'))
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to cancel order'))
                            );
                          }
                        }
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
            ),
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
      case OrderStatus.declined: return 'DECLINED';
      case OrderStatus.declined: return 'DECLINED';
    }
  }
}
