import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_button.dart';
class OrderSummaryCard extends StatelessWidget {
  final String? title;
  final List<Widget>? items;
  final String totalLabel;
  final String totalValue;
  final String? subtitle;
  final String primaryButtonLabel;
  final VoidCallback primaryButtonOnTap;
  final String? secondaryButtonLabel;
  final VoidCallback? secondaryButtonOnTap;
  final bool isSecondaryOutlined;
  final String? footerText;

  const OrderSummaryCard({
    super.key,
    this.title,
    this.items,
    required this.totalLabel,
    required this.totalValue,
    this.subtitle,
    required this.primaryButtonLabel,
    required this.primaryButtonOnTap,
    this.secondaryButtonLabel,
    this.secondaryButtonOnTap,
    this.isSecondaryOutlined = false,
    this.footerText,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color cardBg = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (items != null) ...[
            ...items!,
            const SizedBox(height: 16),
            Divider(color: Colors.grey.withOpacity(0.1)),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalLabel,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                totalValue,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
          const SizedBox(height: 24),
          CustomButton(
            text: primaryButtonLabel,
            type: CustomButtonType.secondary,
            onPressed: primaryButtonOnTap,
          ),
          if (secondaryButtonLabel != null) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: secondaryButtonLabel!,
              type: isSecondaryOutlined ? CustomButtonType.ghost : CustomButtonType.destructive,
              foregroundColor: isSecondaryOutlined ? const Color(0xFFE11D48) : Colors.white,
              onPressed: secondaryButtonOnTap!,
            ),
          ],
          if (footerText != null) ...[
            const SizedBox(height: 20),
            Center(
              child: Text(
                footerText!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
