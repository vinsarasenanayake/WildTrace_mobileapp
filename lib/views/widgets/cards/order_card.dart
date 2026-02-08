import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/common_widgets.dart';

// order card
class OrderCard extends StatelessWidget {
  // order info
  final String status;
  final String orderId;
  final String date;
  final String total;

  // callbacks
  final VoidCallback onPayNow;
  final VoidCallback onCancel;
  final List<Widget> items;
  final String? estimatedDelivery;

  const OrderCard({
    super.key,
    required this.status,
    required this.orderId,
    required this.date,
    required this.total,
    required this.onPayNow,
    required this.onCancel,
    required this.items,
    this.estimatedDelivery,
  });

  // status color helper
  Color _getStatusColor(String status) {
    status = status.trim().toUpperCase();
    if (['DECLINED', 'CANCELLED', 'FAILED'].contains(status)) {
      return const Color(0xFFE11D48); // Red
    } else if (['DELIVERED', 'PAID', 'CONFIRMED', 'SUCCESS'].contains(status)) {
      return const Color(0xFF16A34A); // Green
    }
    return const Color(0xFFF59E0B); // Amber (Pending/Processing)
  }

  // builds card
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    // button visibility logic
    final bool isPending = status.toUpperCase() == 'PENDING';
    final bool showButtons = [
      'PENDING',
      'DECLINED',
      'CANCELLED',
    ].contains(status.toUpperCase());

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // left column: status, id, date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: _getStatusColor(status),
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
                        fontSize: 16, // Slightly smaller to fit layout
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (estimatedDelivery != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Est. Delivery: $estimatedDelivery',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF27AE60),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // right column: total price + buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            total,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF27AE60),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // buttons container
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),
          ...items,

          if (showButtons) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: CustomButton(
                      text: 'PAY NOW',
                      type: isPending
                          ? CustomButtonType.secondary
                          : CustomButtonType.ghost,
                      verticalPadding: 0,
                      backgroundColor: isPending
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFE7E5E4),
                      foregroundColor: isPending
                          ? Colors.white
                          : const Color(0xFFA8A29E),
                      onPressed: isPending ? onPayNow : () {},
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: CustomButton(
                      text: 'CANCEL ORDER',
                      type: CustomButtonType.secondary,
                      verticalPadding: 0,
                      backgroundColor: isPending
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFF5F5F4),
                      foregroundColor: isPending
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF4B5563), // Darker Grey for visibility
                      onPressed: isPending ? onCancel : null,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
