import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/payment_form.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/bottom_nav_bar.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Saved Payment Methods
  final List<Map<String, String>> _savedCards = [
    {'type': 'Visa', 'number': '**** **** **** 4242', 'holder': 'VINSARA SENANAYAKE', 'expiry': '12/28'}
  ];

  // Card Inputs
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
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Text('Wallet', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: textColor)),
      ),
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(), // Title and Add Button
            const SizedBox(height: 16),
            if (_isAddingCard) _buildAddCardForm(isDarkMode, textColor) // Inline Form
            else _buildCardList(), // Saved Cards View
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('PAYMENT METHODS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey.shade500)),
        if (!_isAddingCard) TextButton.icon(
          onPressed: () => setState(() => _isAddingCard = true),
          icon: const Icon(Icons.add, size: 16, color: Color(0xFF2ECC71)),
          label: Text('ADD NEW', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2ECC71))),
        ),
      ],
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
              Expanded(child: _buildButton('CANCEL', Colors.transparent, textColor, () => setState(() => _isAddingCard = false), isOutlined: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildButton('SAVE CARD', const Color(0xFF2ECC71), Colors.white, _saveCard)),
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

  Widget _buildButton(String text, Color bg, Color fg, VoidCallback onTap, {bool isOutlined = false}) {
    final style = isOutlined 
      ? OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
      : ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg, padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
    
    return isOutlined 
      ? OutlinedButton(onPressed: onTap, style: style, child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: fg)))
      : ElevatedButton(onPressed: onTap, style: style, child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)));
  }
}
