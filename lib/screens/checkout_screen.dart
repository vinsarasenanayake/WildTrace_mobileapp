// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/user_form.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/section_title.dart';

// --- Screen ---
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

// --- State ---
class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController(text: 'Pavan');
  final _emailController = TextEditingController(text: 'pavan@gmail.com');
  final _contactController = TextEditingController(text: '+94 111111111');
  final _addressController = TextEditingController(text: 'safasf');
  final _cityController = TextEditingController(text: 'Saf');
  final _postalCodeController = TextEditingController(text: '11111');

  // --- Build Method ---
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
      body: SingleChildScrollView(
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
                const SizedBox(height: 8),
                Text(
                  '',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                ),
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
                    addressLabel: 'SHIPPING ADDRESS',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            OrderSummaryCard(
              title: 'Order Review',
              items: const [
                OrderItem(
                  image: 'assets/images/product6.jpg',
                  title: 'Emerald Green Tree Python',
                  subtitle: '12 x 18 in',
                  quantity: 1,
                  price: 65,
                ),
              ],
              totalLabel: 'Total',
              totalValue: '\$65',
              primaryButtonLabel: 'PROCEED TO PAYMENT',
              primaryButtonOnTap: () {},
              secondaryButtonLabel: 'CANCEL ORDER',
              secondaryButtonOnTap: () => Navigator.pop(context),
              isSecondaryOutlined: true,
              footerText: 'You will be redirected to Stripe\'s secure payment page to complete your purchase.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
