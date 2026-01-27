import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool isObscure;
  final VoidCallback? onToggleVisibility;
  final bool hasToggle;
  final Widget? prefix;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.isObscure = false,
    this.onToggleVisibility,
    this.hasToggle = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white60 : Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
            filled: true,
            fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: prefix,
            suffixIcon: hasToggle 
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          ),
        ),
      ],
    );
  }
}
