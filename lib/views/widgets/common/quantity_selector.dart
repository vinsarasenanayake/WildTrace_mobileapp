import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// quantity selector
class QuantitySelector extends StatelessWidget {
  // state and callbacks
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  // builds selector
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(Icons.remove, onDecrement, isDarkMode),
          SizedBox(
            width: 40,
            child: Center(
              child: Text(
                '$quantity',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                ),
              ),
            ),
          ),
          _buildButton(Icons.add, onIncrement, isDarkMode),
        ],
      ),
    );
  }

  // builds button
  Widget _buildButton(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return InkWell(
      onTap: ((icon == Icons.remove && quantity <= 1) ? null : onTap),
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Opacity(
        opacity: (icon == Icons.remove && quantity <= 1) ? 0.3 : 1.0,
        child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDarkMode
              ? Colors.white.withAlpha((0.05 * 255).round())
              : Colors.grey.shade50,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
        ),
      ),
    ));
  }
}
