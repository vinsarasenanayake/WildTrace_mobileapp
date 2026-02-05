// Imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/cards/order_summary_card.dart';
import 'checkout_screen.dart';
import '../widgets/common/section_title.dart';
import '../widgets/cards/cart_item_card.dart';
import '../../providers/navigation_provider.dart';
import '../widgets/common/custom_button.dart';
import 'package:quickalert/quickalert.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../widgets/common/wildtrace_logo.dart';
import '../../main_wrapper.dart';

// Cart Screen
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Initialize cart data on start
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<CartProvider>(context, listen: false).fetchCart(authProvider.token!);
      }
    });
  }

  // Main build method for cart UI
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
        final cartItems = cartProvider.items;

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (authProvider.token != null) {
                  await cartProvider.fetchCart(authProvider.token!);
                }
              },
              color: const Color(0xFF27AE60),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    floating: true,
                    snap: true,
                    pinned: false,
                    toolbarHeight: 40,
                    automaticallyImplyLeading: false,
                  ),
                  if (cartItems.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context, cartProvider),
                    )
                  else
                    ..._buildCartSlivers(context, cartProvider, textColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Empty state UI when no logged in user
  Widget _buildEmptyState(BuildContext context, CartProvider cartProvider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    if (authProvider.token == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const SizedBox(height: 20),
            Icon(Icons.lock_outline, size: 64, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'Personalize Your Experience',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to view your cart items, manage orders, and checkout faster.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'SIGN IN NOW',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              type: CustomButtonType.secondary,
              fontSize: 13,
              verticalPadding: 18,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'REGISTER NOW',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
              type: CustomButtonType.ghost,
              fontSize: 13,
              verticalPadding: 18,
            ),
            const SizedBox(height: 30),
            _buildFooter(),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty', 
            style: GoogleFonts.inter(
              fontSize: 14, 
              color: Colors.grey.shade500, 
              fontWeight: FontWeight.w500
            )
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
               if (authProvider.token != null) {
                 cartProvider.fetchCart(authProvider.token!);
               }
            }, 
            icon: const Icon(Icons.refresh, size: 18), 
            label: const Text('Refresh Cart'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF27AE60),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: 220,
              child: CustomButton(
                text: 'EXPLORE GALLERY',
                type: CustomButtonType.secondary,
                onPressed: () {
                  Provider.of<NavigationProvider>(context, listen: false).setSelectedIndex(1);
                },
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // UI sections for the shopping cart items
  List<Widget> _buildCartSlivers(BuildContext context, CartProvider cartProvider, Color textColor) {
    final cartItems = cartProvider.items;
    
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SectionTitle(title: 'YOUR SELECTION', mainAxisAlignment: MainAxisAlignment.center),
              const SizedBox(height: 12),
              Text(
                'Collectors Cart', 
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36, 
                  fontWeight: FontWeight.w400, 
                  fontStyle: FontStyle.italic, 
                  color: textColor
                )
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) return const SizedBox(height: 16);
              final itemIndex = index ~/ 2;
              final item = cartItems[itemIndex];
              
              return CartItemCard(
                image: item.product.imageUrl, 
                category: item.product.category, 
                title: item.product.title, 
                price: item.price ?? item.product.price, 
                quantity: item.quantity,
                size: item.size,
                onIncrement: () => cartProvider.incrementQuantity(item),
                onDecrement: () => cartProvider.decrementQuantity(item),
                onDelete: () {
                  if (item.id != null) {
                    cartProvider.removeFromCart(item.id!);
                  }
                },
                onDismissed: () {
                  if (item.id != null) {
                    final cartItemId = item.id!;
                    final productName = item.product.title;
                    cartProvider.removeFromCart(cartItemId);
                    
                    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.info,
                      title: 'Item Removed',
                      text: '$productName removed from cart',
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      titleColor: isDarkMode ? Colors.white : Colors.black,
                      textColor: isDarkMode ? Colors.white70 : Colors.black87,
                    );
                  }
                },
              );
            },
            childCount: cartItems.length * 2 - 1,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildSummaryCard(context, cartProvider),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: _buildFooter(),
        ),
      ),
    ];
  }

  // Summary card with total price and checkout
  Widget _buildSummaryCard(BuildContext context, CartProvider cartProvider) {
    return OrderSummaryCard(
      title: 'Cart Summary',
      totalLabel: 'ORDER TOTAL',
      totalValue: '\$${cartProvider.total.toStringAsFixed(0)}',
      primaryButtonLabel: 'PROCEED TO CHECKOUT',
      primaryButtonOnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CheckoutScreen()),
        );
      },
      secondaryButtonLabel: 'CLEAR CART',
      secondaryButtonOnTap: () => cartProvider.clearCart(),
      isSecondaryOutlined: true,
    );
  }
  // Footer section with copyright info
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Copyright © 2026 ', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
        InkWell(
          onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainWrapper()), (route) => false),
          child: Text('WILDTRACE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60)))
        ),
        Text('. All Rights Reserved.', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}
