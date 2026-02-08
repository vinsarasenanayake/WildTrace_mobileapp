import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// application theme configuration
class AppTheme {
  // primary brand color
  static const Color primaryGreen = Color(0xFF1B4332);

  // light theme definition
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        primaryColor: primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        iconButtonTheme: _iconButtonTheme,
      );

  // dark theme definition
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        primaryColor: primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        iconButtonTheme: _iconButtonTheme,
      );

  // button styles
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
      elevation: 0,
    ),
  );

  static final _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      splashFactory: NoSplash.splashFactory,
    ),
  );

  static final _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory),
  );

  static final _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(splashFactory: NoSplash.splashFactory),
  );
}
