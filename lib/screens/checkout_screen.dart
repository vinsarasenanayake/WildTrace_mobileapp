import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/user_form.dart';
import '../widgets/order_summary_card.dart';
import '../widgets/section_container.dart';
import '../widgets/order_item.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/wildtrace_back_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController(text: 'Pavan');
  final _emailController = TextEditingController(text: 'pavan@gmail.com');
  final _contactController = TextEditingController(text: '+94 111111111');
  final _addressController = TextEditingController(text: 'safasf');
  final _cityController = TextEditingController(text: 'Saf');
  final _postalCodeController = TextEditingController(text: '11111');

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
        leading: const WildTraceBackButton(),
        title: Text(
          'Complete Purchase',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          children: [
            Text(
              'FINAL STEP',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
                color: const Color(0xFF2ECC71),
              ),
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
            
            SectionContainer(
              title: 'Shipping Details',
              description: '',
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
