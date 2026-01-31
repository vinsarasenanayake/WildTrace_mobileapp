import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/custom_button.dart';
import 'order_item_card.dart';

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
    
    // Determine button states based on status
    final bool isPending = status.toUpperCase() == 'PENDING';
    final bool showButtons = ['PENDING', 'DECLINED', 'CANCELLED'].contains(status.toUpperCase());

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
          // Header Row: Status & Order Details + Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Status, Order #, Date
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
                        color: ['DECLINED', 'CANCELLED', 'FAILED'].contains(status.trim().toUpperCase()) 
                            ? const Color(0xFFE11D48) // Red
                            : (['DELIVERED', 'PAID', 'CONFIRMED', 'SUCCESS'].contains(status.trim().toUpperCase())
                                ? const Color(0xFF16A34A) // Green (Tailwind green-600)
                                : const Color(0xFFF59E0B)), // Amber
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
                  ],
                ),
              ),
              
              // Right Column: Total Price + Action Buttons (if visible)
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
                                color: const Color(0xFF2ECC71),
                              ),
                            ),
                          ],
                        ),
                     ],
                   ),
                   const SizedBox(height: 12),
                   // Buttons moved to bottom row
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
                      type: CustomButtonType.secondary,
                      verticalPadding: 0,
                      backgroundColor: isPending ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4),
                      foregroundColor: isPending ? Colors.white : const Color(0xFFA8A29E),
                      onPressed: isPending ? onPayNow : null,
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
                      backgroundColor: isPending ? const Color(0xFFFEF2F2) : const Color(0xFFF5F5F4),
                      foregroundColor: isPending ? const Color(0xFFEF4444) : const Color(0xFFD6D3D1),
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


