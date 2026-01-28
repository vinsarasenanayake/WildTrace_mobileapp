// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_text_field.dart';

// --- Screen ---
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

// --- State ---
class _WalletScreenState extends State<WalletScreen> {
  final List<Map<String, String>> _savedCards = [
    {'type': 'Visa', 'number': '4242 4242 4242 4242', 'holder': 'VINSARA SENANAYAKE', 'expiry': '12/28', 'cvv': '123'}
  ];
  final TextEditingController _numCtrl = TextEditingController();
  final TextEditingController _expCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  bool _isAddingCard = false;

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
        centerTitle: true,
        title: Text('Wallet', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: textColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PAYMENT METHODS',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (!_isAddingCard)
                  TextButton(
                    onPressed: () => setState(() => _isAddingCard = true),
                    child: Text(
                      'ADD NEW',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2ECC71),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isAddingCard) _buildAddCardForm(isDarkMode, textColor)
            else _buildCardList(),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
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
        'number': _numCtrl.text,
        'holder': _nameCtrl.text.toUpperCase(),
        'expiry': _expCtrl.text,
        'cvv': _cvvCtrl.text,
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
        return PaymentMethodCard(type: card['type']!, number: card['number']!, expiry: card['expiry']!, cvv: card['cvv']!, onDelete: () => setState(() => _savedCards.removeAt(index)));
      },
    );
  }
}

// --- Widgets ---
class PaymentMethodCard extends StatelessWidget {
  final String type;
  final String number;
  final String expiry;
  final String cvv;
  final VoidCallback? onDelete;

  const PaymentMethodCard({
    super.key,
    required this.type,
    required this.number,
    required this.expiry,
    required this.cvv,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        )
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF1B4332), 
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              type == 'Visa' ? 'VISA' : 'MC',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Expires $expiry',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 10, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    Text(
                      'CVV $cvv',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 20),
            ),
        ],
      ),
    );
  }
}

class PaymentForm extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController holderNameController;

  const PaymentForm({
    super.key,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.holderNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Card Number',
          controller: cardNumberController,
          hintText: '0000 0000 0000 0000',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Expiry',
                controller: expiryController,
                hintText: 'MM/YY',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'CVV',
                controller: cvvController,
                hintText: '123',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Cardholder Name',
          controller: holderNameController,
          hintText: 'FULL NAME',
        ),
      ],
    );
  }
}





