import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary_card.dart';
import 'checkout_screen.dart';
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {'image': 'assets/images/product4.jpg', 'category': 'MUSEUM PRINT', 'title': 'Clownfish in Anemone', 'price': 120.0, 'quantity': 1},
    {'image': 'assets/images/product3.jpg', 'category': 'LIMITED EDITION', 'title': 'Elephant Walk', 'price': 180.0, 'quantity': 1},
  ];
  double get _totalPrice => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));

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
        automaticallyImplyLeading: false,
        title: Text(
          'Cart',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: _cartItems.isEmpty ? _buildEmptyState() : _buildCartList(textColor),
      ),
    );
  }
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
  Widget _buildCartList(Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          Text('YOUR SELECTION', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: const Color(0xFF2ECC71))),
          const SizedBox(height: 8),
          Text('Collectors Cart', style: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: textColor)),
          const SizedBox(height: 32),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
            itemCount: _cartItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildCartItem(index),
          ),
          const SizedBox(height: 40),
          _buildSummaryCard(context, textColor),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return CartItemCard(
      image: item['image'], category: item['category'], title: item['title'], price: item['price'], quantity: item['quantity'],
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
