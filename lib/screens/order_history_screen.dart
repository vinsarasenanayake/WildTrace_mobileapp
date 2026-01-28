// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/order_card.dart';

// --- Screen ---
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  // --- Build Method ---
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
                  subtitle: '12 x 18 in',
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

// --- Widgets ---

