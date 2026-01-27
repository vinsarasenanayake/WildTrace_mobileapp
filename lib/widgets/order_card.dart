import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          // Top Metadata
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
                      color: const Color(0xFFF59E0B), // Orange color
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
              
              // Order Summary
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
          
          // Control Options
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16), // Taller button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'PAY NOW',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 140,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: onCancel,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16), // Match height
                        child: Text(
                          'CANCEL ORDER',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 24),

          // Itemized Manifest
          ...items,
        ],
      ),
    );
  }
}
