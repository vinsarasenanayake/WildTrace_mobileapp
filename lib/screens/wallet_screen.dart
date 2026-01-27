import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/payment_form.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/section_header.dart';
import '../widgets/wildtrace_back_button.dart';
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}
class _WalletScreenState extends State<WalletScreen> {
  final List<Map<String, String>> _savedCards = [
    {'type': 'Visa', 'number': '**** **** **** 4242', 'holder': 'VINSARA SENANAYAKE', 'expiry': '12/28'}
  ];
  final TextEditingController _numCtrl = TextEditingController();
  final TextEditingController _expCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  bool _isAddingCard = false;

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
        centerTitle: true,
        title: Text('Wallet', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: textColor)),
      ),
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'PAYMENT METHODS',
              actionLabel: _isAddingCard ? null : 'ADD NEW',
              onActionPressed: () => setState(() => _isAddingCard = true),
            ),
            const SizedBox(height: 16),
            if (_isAddingCard) _buildAddCardForm(isDarkMode, textColor)
            else _buildCardList(),
          ],
        ),
      ),
    );
  }
  Widget _buildAddCardForm(bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add New Card', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 24),
          PaymentForm(cardNumberController: _numCtrl, expiryController: _expCtrl, cvvController: _cvvCtrl, holderNameController: _nameCtrl),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: CustomButton(text: 'CANCEL', type: CustomButtonType.ghost, onPressed: () => setState(() => _isAddingCard = false))),
              const SizedBox(width: 16),
              Expanded(child: CustomButton(text: 'SAVE CARD', type: CustomButtonType.secondary, onPressed: _saveCard)),
            ],
          ),
        ],
      ),
    );
  }
  void _saveCard() {
    setState(() {
      _savedCards.add({
        'type': 'Visa',
        'number': '**** **** **** ${_numCtrl.text.length >= 4 ? _numCtrl.text.substring(_numCtrl.text.length - 4) : '0000'}',
        'holder': _nameCtrl.text.toUpperCase(),
        'expiry': _expCtrl.text,
      });
      _numCtrl.clear(); _nameCtrl.clear(); _expCtrl.clear(); _cvvCtrl.clear();
      _isAddingCard = false;
    });
  }
  Widget _buildCardList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
      itemCount: _savedCards.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final card = _savedCards[index];
        return PaymentMethodCard(type: card['type']!, number: card['number']!, expiry: card['expiry']!, onDelete: () => setState(() => _savedCards.removeAt(index)));
      },
    );
  }
}
