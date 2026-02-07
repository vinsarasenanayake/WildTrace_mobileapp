import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order.dart';
import '../../utils/responsive_helper.dart';
import 'order_history_screen.dart';
import '../widgets/forms/user_form.dart';
import '../widgets/cards/order_summary_card.dart';
import '../widgets/cards/order_item_card.dart';
import '../widgets/common/section_title.dart';
import '../../services/api_service.dart';
import 'package:quickalert/quickalert.dart';
import 'package:intl/intl.dart' as intl;
import '../../controllers/battery_controller.dart';
import '../widgets/common/battery_status_indicator.dart';

// handles checkout process
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // form field controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  // initializes controllers with current user data
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthController>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController(text: user?.contactNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }

  // releases controller resources
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

  // builds the checkout workflow interface
  @override
  Widget build(BuildContext context) {
    // theme and layout detection
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
          appBar: AppBar(
            backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            // back navigation control
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
              'Complete Purchase',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          body: Consumer2<CartController, OrdersController>(
            builder: (context, cartProvider, ordersProvider, child) {
              final cartItems = cartProvider.items;
              final totalAmount = cartProvider.total;
              
              // prevents checkout if cart is empty
              if (cartItems.isEmpty) {
                 return Center(child: Text("Cart is empty", style: GoogleFonts.inter(color: textColor)));
              }

              // defines user information input section
              final shippingDetailsWidget = Column(
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
              );

              final batteryProvider = Provider.of<BatteryController>(context);
              final isBatteryLow = batteryProvider.isBatteryLow;

              // defines financial and item summary section
              final orderSummaryWidget = OrderSummaryCard(
                title: 'Order Review',
                items: cartItems.map((item) => OrderItem(
                  image: item.product.imageUrl,
                  title: item.product.title,
                  subtitle: item.size,
                  quantity: item.quantity,
                  price: item.price ?? item.product.price,
                )).toList(),
                totalLabel: 'Total',
                totalValue: '\$${totalAmount.toStringAsFixed(2)}',
                primaryButtonLabel: isBatteryLow ? 'BATTERY LOW' : 'PROCEED TO PAYMENT',
                isPrimaryEnabled: !isBatteryLow,
                // initiates secure payment flow
                primaryButtonOnTap: () async {
                  final authProvider = Provider.of<AuthController>(context, listen: false);
                  final user = authProvider.currentUser;
                  final token = authProvider.token;

                  // ensures user is authenticated before payment
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

                  // launches stripe payment integration
                  await StripeService.instance.makePayment(
                    amount: totalAmount,
                    currency: 'USD',
                    context: context,
                    onSuccess: () async {
                      // places order after verified payment
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
                      
                      // handles order placement result
                      if (success) {
                          await cartProvider.resetAfterOrder(token: token);
                          if (context.mounted) {
                            final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                            final estimatedDate = DateTime.now().add(const Duration(days: 3));
                            final formattedDate = intl.DateFormat('MMMM dd, yyyy').format(estimatedDate);
                             
                            // displays success confirmation
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              title: 'Order Placed!',
                              text: 'Order placed successfully! \nEstimated Delivery: $formattedDate',
                              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                              titleColor: isDarkMode ? Colors.white : Colors.black,
                              textColor: isDarkMode ? Colors.white70 : Colors.black87,
                              confirmBtnText: 'GO TO ORDER HISTORY',
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
                          // reports data persistence failure
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
              );

              // assembles the scrollable layout
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  children: [
                    // header branding section
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
                    
                    // adaptive layout for different orientations
                    isLandscape 
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: shippingDetailsWidget),
                            const SizedBox(width: 24),
                            Expanded(child: orderSummaryWidget),
                          ],
                        )
                      : Column(
                          children: [
                            shippingDetailsWidget,
                            const SizedBox(height: 32),
                            orderSummaryWidget,
                          ],
                        ),
                        
                    // bottom spacing
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 20,
          child: const BatteryStatusIndicator(),
        ),
      ],
    );
  }
}
