// Imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import 'order_history_screen.dart';
import '../widgets/forms/user_form.dart';
import '../widgets/cards/order_summary_card.dart';
import '../widgets/cards/order_item_card.dart';
import '../widgets/common/section_title.dart';
import '../../services/api_service.dart';
import 'package:quickalert/quickalert.dart';

// Checkout Screen
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

// Checkout State
class _CheckoutScreenState extends State<CheckoutScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  // Initialize controllers with user data
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController(text: user?.contactNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }

  // Clean up resources when screen is closed
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Build Method
  // Main build method for checkout flow
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
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
        title: Text(
          'Complete Purchase',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: Consumer2<CartProvider, OrdersProvider>(
        builder: (context, cartProvider, ordersProvider, child) {
          final cartItems = cartProvider.items;
          final totalAmount = cartProvider.totalAmount;
          
          if (cartItems.isEmpty) {
             return Center(child: Text("Cart is empty", style: GoogleFonts.inter(color: textColor)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              children: [
                const SectionTitle(title: 'FINAL STEP', mainAxisAlignment: MainAxisAlignment.center),
                const SizedBox(height: 8),
                Text(
                  'Complete Purchase',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: 'Shipping Details', showLine: false),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: UserForm(
                        nameController: _nameController,
                        emailController: _emailController,
                        contactController: _contactController,
                        addressController: _addressController,
                        cityController: _cityController,
                        postalCodeController: _postalCodeController,
                        countryController: _countryController,
                        addressLabel: 'SHIPPING ADDRESS',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                OrderSummaryCard(
                  title: 'Order Review',
                  items: cartItems.map((item) => OrderItem(
                    image: item.product.imageUrl,
                    title: item.product.title,
                    subtitle: item.product.category,
                    quantity: item.quantity,
                    price: item.product.price,
                  )).toList(),
                  totalLabel: 'Total',
                  totalValue: '\$${totalAmount.toStringAsFixed(2)}',
                  primaryButtonLabel: 'PROCEED TO PAYMENT',
                  primaryButtonOnTap: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final user = authProvider.currentUser;
                    final token = authProvider.token;

                    if (user == null || token == null) {
                      final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      QuickAlert.show(
                        context: context,
                        type: QuickAlertType.warning,
                        title: 'Authentication Required',
                        text: 'Please login to complete your purchase.',
                        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        titleColor: isDarkMode ? Colors.white : Colors.black,
                        textColor: isDarkMode ? Colors.white70 : Colors.black87,
                      );
                      return;
                    }

                    // Start Stripe Payment
                    await StripeService.instance.makePayment(
                      amount: totalAmount,
                      currency: 'USD',
                      context: context,
                      onSuccess: () async {
                        // If payment success, place the order
                        final success = await ordersProvider.placeOrder(
                          userId: user.id,
                          items: List.from(cartItems),
                          subtotal: cartProvider.subtotal,
                          tax: cartProvider.tax,
                          shipping: cartProvider.shipping,
                          shippingAddress: '${_addressController.text}, ${_cityController.text}, ${_postalCodeController.text}',
                          token: token,
                          paymentStatus: 'paid',
                        );
                        
                        if (success) {
                            await cartProvider.resetAfterOrder(token: token);
                            if (context.mounted) {
                              final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.success,
                                title: 'Order Placed!',
                                text: 'Order placed and paid successfully!',
                                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                titleColor: isDarkMode ? Colors.white : Colors.black,
                                textColor: isDarkMode ? Colors.white70 : Colors.black87,
                                confirmBtnText: 'Okay',
                                confirmBtnTextStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                onConfirmBtnTap: () {
                                  Navigator.pop(context); // Close alert
                                  Navigator.pushReplacement(
                                    context, 
                                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen())
                                  );
                                },
                              );
                            }
                        } else {
                            if (context.mounted) {
                              final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Order Error',
                                text: 'Payment was successful, but failed to record order. Please contact support.',
                                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                titleColor: isDarkMode ? Colors.white : Colors.black,
                                textColor: isDarkMode ? Colors.white70 : Colors.black87,
                              );
                            }
                        }
                      },
                    );
                  },
                  secondaryButtonLabel: 'CANCEL ORDER',
                  secondaryButtonOnTap: () => Navigator.pop(context),
                  isSecondaryOutlined: true,
                  footerText: 'You will be redirected to Stripe\'s secure payment page to complete your purchase.',
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
