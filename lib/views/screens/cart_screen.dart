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

// Cart Screen
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
              color: const Color(0xFF2ECC71),
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

  // Helper Methods
  Widget _buildEmptyState(BuildContext context, CartProvider cartProvider) {
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
               final authProvider = Provider.of<AuthProvider>(context, listen: false);
               if (authProvider.token != null) {
                 cartProvider.fetchCart(authProvider.token!);
               }
            }, 
            icon: const Icon(Icons.refresh, size: 18), 
            label: const Text('Refresh Cart'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2ECC71),
            ),
          ),
          if (Provider.of<AuthProvider>(context, listen: false).token != null)
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
        ],
      ),
    );
  }

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
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$productName removed'), 
                      )
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
    ];
  }

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
  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
