// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/order_summary_card.dart';
import 'checkout_screen.dart';
import '../widgets/section_title.dart';
import '../widgets/cart_item_card.dart';

// --- Screen ---
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

// --- State ---
class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {'image': 'assets/images/product4.jpg', 'category': 'MUSEUM PRINT', 'title': 'Clownfish in Anemone', 'price': 120.0, 'quantity': 1},
    {'image': 'assets/images/product3.jpg', 'category': 'LIMITED EDITION', 'title': 'Elephant Walk', 'price': 180.0, 'quantity': 1},
  ];
  double get _totalPrice => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      body: SafeArea(
        child: CustomScrollView(
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
            if (_cartItems.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else ..._buildCartSlivers(textColor),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Your cart is empty', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  List<Widget> _buildCartSlivers(Color textColor) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SectionTitle(title: 'YOUR SELECTION', mainAxisAlignment: MainAxisAlignment.center),
              const SizedBox(height: 12),
              Text('Collectors Cart', style: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: textColor)),
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
              return _buildCartItem(itemIndex);
            },
            childCount: _cartItems.length * 2 - 1,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildSummaryCard(context, textColor),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return CartItemCard(
      image: item['image'], 
      category: item['category'], 
      title: item['title'], 
      price: item['price'], 
      quantity: item['quantity'],
      onIncrement: () => setState(() => _cartItems[index]['quantity']++),
      onDecrement: () => setState(() { if (item['quantity'] > 1) _cartItems[index]['quantity']--; }),
      onDelete: () => setState(() => _cartItems.removeAt(index)),
      onDismissed: () {
        final removedItem = _cartItems[index];
        setState(() => _cartItems.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${removedItem['title']} removed'), action: SnackBarAction(label: 'UNDO', onPressed: () => setState(() => _cartItems.insert(index, removedItem)))));
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, Color textColor) {
    return OrderSummaryCard(
      title: 'Cart Summary',
      totalLabel: 'ORDER TOTAL',
      totalValue: '\$${_totalPrice.toInt()}',
      subtitle: 'Including taxes and shipping',
      primaryButtonLabel: 'PROCEED TO CHECKOUT',
      primaryButtonOnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CheckoutScreen()),
        );
      },
      secondaryButtonLabel: 'CLEAR CART',
      secondaryButtonOnTap: () => setState(() => _cartItems.clear()),
      isSecondaryOutlined: true,
    );
  }
}

