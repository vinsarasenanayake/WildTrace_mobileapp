import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertService {
  
  static void showError({
    required BuildContext context,
    String title = 'Error',
    required String text,
    String confirmBtnText = 'Okay',
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: title,
      text: text,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      titleColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.white70 : Colors.black87,
      confirmBtnText: confirmBtnText,
      confirmBtnTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static void showWarning({
    required BuildContext context,
    String title = 'Warning',
    required String text,
    String confirmBtnText = 'Okay',
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: title,
      text: text,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      titleColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.white70 : Colors.black87,
      confirmBtnText: confirmBtnText,
      confirmBtnTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    String title = 'Success',
    required String text,
    String confirmBtnText = 'Okay',
    VoidCallback? onConfirmBtnTap,
  }) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: title,
      text: text,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      titleColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.white70 : Colors.black87,
      confirmBtnText: confirmBtnText,
      confirmBtnTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  static void showConfirmation({
    required BuildContext context,
    String title = 'Confirm',
    required String text,
    String confirmBtnText = 'Yes',
    String cancelBtnText = 'No',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color? confirmBtnColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: title,
      text: text,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      titleColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.white70 : Colors.black87,
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
      confirmBtnColor: confirmBtnColor ?? const Color(0xFF3498DB),
      confirmBtnTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      cancelBtnTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: isDarkMode ? Colors.white : Colors.red,
        fontWeight: FontWeight.bold,
      ),
      onConfirmBtnTap: onConfirm,
      onCancelBtnTap: onCancel,
    );
  }

  static void showInfo({
    required BuildContext context,
    String title = 'Info',
    required String text,
    String confirmBtnText = 'Okay',
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: title,
      text: text,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      titleColor: isDarkMode ? Colors.white : Colors.black,
      textColor: isDarkMode ? Colors.white70 : Colors.black87,
      confirmBtnText: confirmBtnText,
      confirmBtnTextStyle: GoogleFonts.inter(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  static void showCustom({
    required BuildContext context,
    required Widget widget,
    String title = 'Info',
    String text = '',
    QuickAlertType type = QuickAlertType.custom,
    String confirmBtnText = 'Okay',
    bool showConfirmBtn = true,
  }) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      
      QuickAlert.show(
        context: context,
        type: type,
        title: title,
        text: text,
        widget: widget,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        titleColor: isDarkMode ? Colors.white : Colors.black,
        textColor: isDarkMode ? Colors.white70 : Colors.black87,
        confirmBtnText: confirmBtnText,
        showConfirmBtn: showConfirmBtn,
      );
  }
}
