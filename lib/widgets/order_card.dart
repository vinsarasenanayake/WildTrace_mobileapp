import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_button.dart';

class OrderCard extends StatelessWidget {
  final String status;
  final String orderId;
  final String date;
  final String total;
  final VoidCallback onPayNow;
  final VoidCallback onCancel;
  final List<Widget> items;

  const OrderCard({
    super.key,
    required this.status,
    required this.orderId,
    required this.date,
    required this.total,
    required this.onPayNow,
    required this.onCancel,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderId.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   Text(
                    'TOTAL',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Colors.grey.shade400,
                    ),
                  ),
                   Text(
                    total,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2ECC71),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'PAY NOW',
                  type: CustomButtonType.secondary,
                  onPressed: onPayNow,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'CANCEL ORDER',
                  type: CustomButtonType.ghost,
                  foregroundColor: const Color(0xFFE11D48),
                  onPressed: onCancel,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 24),
          ...items,
        ],
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String image;
  final String title;
  final int quantity;
  final double price;
  final String? subtitle;

  const OrderItem({
    super.key,
    required this.image,
    required this.title,
    required this.quantity,
    required this.price,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              image, width: 60, height: 60, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle != null ? '$title ($subtitle)' : title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'QTY: $quantity • \$${price.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(price * quantity).toInt()}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2ECC71),
            ),
          ),
        ],
      ),
    );
  }
}
