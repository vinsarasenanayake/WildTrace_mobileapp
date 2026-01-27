import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/order_card.dart';
import '../widgets/order_item.dart';
import '../widgets/bottom_nav_bar.dart';

// Past and Pending Orders
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'ORDER HISTORY',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: textColor,
          ),
        ),
      ),
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            OrderCard(
              status: 'PENDING',
              orderId: 'ORDER #5',
              date: 'January 17, 2026',
              total: '\$840.00',
              onPayNow: () {},
              onCancel: () {},
              items: const [
                OrderItem(
                  image: 'assets/images/product4.jpg', 
                  title: 'Clownfish in Anemone',
                  quantity: 2,
                  price: 420.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
