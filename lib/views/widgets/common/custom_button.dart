// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// BUTTON TYPES
// ============================================================================
enum CustomButtonType { primary, secondary, ghost, destructive }

// ============================================================================
// CUSTOM BUTTON WIDGET
// ============================================================================
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double verticalPadding;
  final double fontSize;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = CustomButtonType.primary,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.verticalPadding = 18,
    this.fontSize = 14,
    this.isLoading = false,
  });

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;
    
    // Disable interaction if loading
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    switch (type) {
      case CustomButtonType.primary:
        bg = backgroundColor ?? (isDarkMode ? Colors.white : const Color(0xFF1B1B1B));
        fg = foregroundColor ?? (isDarkMode ? Colors.black : Colors.white);
        break;
      case CustomButtonType.secondary:
        bg = backgroundColor ?? const Color(0xFF2ECC71);
        fg = foregroundColor ?? Colors.white;
        break;
      case CustomButtonType.destructive:
        bg = backgroundColor ?? const Color(0xFFE11D48);
        fg = foregroundColor ?? Colors.white;
        break;
      case CustomButtonType.ghost:
        bg = Colors.transparent;
        fg = foregroundColor ?? (isDarkMode ? Colors.white : const Color(0xFF1B4332));
        border = BorderSide(color: Colors.grey.withOpacity(0.5));
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 24),
      side: border,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      // If disabled (loading), keep the opacity higher if we want to show loading spinner clearly on the same background
      disabledBackgroundColor: bg.withOpacity(0.8), 
      disabledForegroundColor: fg.withOpacity(0.8),
    );

    Widget child = isLoading 
      ? SizedBox(
          width: fontSize + 4, 
          height: fontSize + 4, 
          child: CircularProgressIndicator(
             strokeWidth: 2, 
             valueColor: AlwaysStoppedAnimation<Color>(fg)
          )
        )
      : Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        );
        
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: buttonStyle,
        child: child,
      ),
    );
  }
}
