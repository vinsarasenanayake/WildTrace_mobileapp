import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controllers/cart_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../controllers/auth_controller.dart';
import 'order_history_screen.dart';
import '../widgets/forms/form_widgets.dart';
import '../widgets/cards/card_widgets.dart';
import '../widgets/common/common_widgets.dart';
import '../../services/api/index.dart';

import '../../utilities/alert_service.dart';
import 'package:intl/intl.dart' as intl;
import '../../models/order.dart';


// checkout screen
class CheckoutScreen extends StatefulWidget {
  final Order? pendingOrder;
  const CheckoutScreen({super.key, this.pendingOrder});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  bool _isPaying = false;

  // init state
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController(text: user?.contactNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }

  // dispose
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

  // builds checkout screen
  @override
  Widget build(BuildContext context) {
    // theme data
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color(0xFFF9FBF9),
          appBar: AppBar(
            backgroundColor: isDarkMode
                ? Colors.black
                : const Color(0xFFF9FBF9),
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            // back button
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
              'Checkout Screen',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Consumer2<CartController, OrdersController>(
            builder: (context, cartProvider, ordersProvider, child) {
              final isPendingPayment = widget.pendingOrder != null;
              final List<dynamic> cartItems = isPendingPayment 
                  ? widget.pendingOrder!.items 
                  : cartProvider.items;
              final double totalAmount = isPendingPayment 
                  ? widget.pendingOrder!.total 
                  : cartProvider.total;

              // checks if empty
              if (cartItems.isEmpty) {
                return Center(
                  child: Text(
                    "No items to checkout",
                    style: GoogleFonts.inter(color: textColor),
                  ),
                );
              }

              // shipping form
              final shippingDetailsWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Shipping Details',
                    showLine: false,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
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



              // order summary
              final orderSummaryWidget = OrderSummaryCard(
                title: 'Order Review',
                items: cartItems
                    .map(
                      (item) => OrderItem(
                        image: item.product.imageUrl,
                        title: item.product.title,
                        subtitle: item.size,
                        quantity: item.quantity,
                        price: item.price ?? item.product.price,
                      ),
                    )
                    .toList(),
                totalLabel: 'Total',
                totalValue: '\$${totalAmount.toStringAsFixed(2)}',
                primaryButtonLabel: 'PROCEED TO PAYMENT',
                isPrimaryEnabled: !_isPaying,
                // payment flow
                primaryButtonOnTap: () async {
                  final authProvider = Provider.of<AuthController>(
                    context,
                    listen: false,
                  );
                  final user = authProvider.currentUser;
                  final token = authProvider.token;

                  // check auth
                  if (user == null || token == null) {
                    AlertService.showWarning(
                      context: context,
                      title: 'Authentication Required',
                      text: 'Please login to complete your purchase.',
                    );
                    return;
                  }

                  // stripe start
                  try {
                    setState(() => _isPaying = true);
                    await StripeService.instance.makePayment(
                      amount: totalAmount,
                      currency: 'USD',
                      context: context,
                      onSuccess: () async {
                        // loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(color: Color(0xFF27AE60)),
                          ),
                        );

                        bool success = false;

                        if (isPendingPayment) {
                          // updates status
                          success = await ordersProvider.updatePaymentStatus(
                             widget.pendingOrder!.id, 
                             'paid'
                          );
                        } else {
                          // places order
                          success = await ordersProvider.placeOrder(
                            userId: user.id,
                            items: cartProvider.items,
                            subtotal: cartProvider.subtotal,
                            tax: cartProvider.tax,
                            shipping: cartProvider.shipping,
                            shippingAddress:
                                '${_addressController.text}, ${_cityController.text}, ${_postalCodeController.text}',
                            token: token,
                            paymentStatus: 'paid',
                          );
                        }

                        // closes loading
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }

                        // handles result
                        if (success) {
                          if (!isPendingPayment) {
                             await cartProvider.resetAfterOrder(token: token);
                          }
                          
                          if (context.mounted) {

                            final estimatedDate = DateTime.now().add(
                              const Duration(days: 3),
                            );
                            final formattedDate = intl.DateFormat(
                              'MMMM dd, yyyy',
                            ).format(estimatedDate);

                            // success alert
                            AlertService.showSuccess(
                              context: context,
                              title: 'Order Placed!',
                              text:
                                  'Order placed successfully! \nEstimated Delivery: $formattedDate',
                              confirmBtnText: 'GO TO ORDER HISTORY',
                              onConfirmBtnTap: () {
                                // close alert
                                Navigator.of(context).pop();
                                // nav to history
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OrderHistoryScreen(),
                                  ),
                                );
                              },
                            );
                          }
                        } else {
                        if (context.mounted) {
                          AlertService.showError(
                            context: context,
                            title: 'Order Error',
                            text: 'Payment successful, but order update failed.',
                          );
                         }
                        }
                      },
                    );
                  } catch (e) {

                    AlertService.showError(
                      context: context,
                      title: 'Payment Error',
                      text: 'Unable to initialize payment: $e',
                    );
                  } finally {
                    if (mounted) setState(() => _isPaying = false);
                  }
                },
                secondaryButtonLabel: isPendingPayment ? 'CANCEL' : 'CANCEL ORDER',
                secondaryButtonOnTap: () {
                   if (isPendingPayment) {
                     Navigator.pop(context);
                   } else {
                     AlertService.showConfirmation(
                      context: context,
                      title: 'Cancel Order',
                      text: 'Are you sure? This will save the order as pending and clear your cart.',
                      confirmBtnText: 'Yes, Cancel',
                      cancelBtnText: 'No',
                      onConfirm: () async {
                        Navigator.pop(context); // Close alert

                        // loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );

                        final authProvider = Provider.of<AuthController>(context, listen: false);
                        final user = authProvider.currentUser;
                        final token = authProvider.token;

                        if (user != null && token != null) {
                           final success = await ordersProvider.placeOrder(
                              userId: user.id,
                              items: cartProvider.items,
                              subtotal: cartProvider.subtotal,
                              tax: cartProvider.tax,
                              shipping: cartProvider.shipping,
                              shippingAddress: '${_addressController.text}, ${_cityController.text}, ${_postalCodeController.text}',
                              token: token,
                              paymentStatus: 'pending',
                           );

                           if (context.mounted) {
                             Navigator.pop(context); // closes loading
                             if (success) {
                                await cartProvider.clearCart();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                                );
                             } else {
                                AlertService.showError(context: context, title: 'Error', text: 'Failed to create pending order.');
                             }
                           }
                        } else {
                           if(context.mounted) Navigator.pop(context); // closes loading
                        }
                      },
                      onCancel: () => Navigator.pop(context),
                     );
                   }
                },
                isSecondaryOutlined: true,
                footerText:
                    'You will be redirected to Stripe\'s secure payment page to complete your purchase.',
              );

              // scroll layout
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  children: [
                    // header
                    const SectionTitle(
                      title: 'FINAL STEP',
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
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

                    // responsive content
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

                    // spacing
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
           ),
          ),
        );
      }
    }
