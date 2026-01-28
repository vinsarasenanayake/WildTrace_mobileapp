// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/navigation_provider.dart';
import 'screens/splash_screen.dart';

// ============================================================================
// MAIN ENTRY POINT
// ============================================================================
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const WildTraceApp(),
    ),
  );
}

// ============================================================================
// WILD TRACE APP
// ============================================================================
class WildTraceApp extends StatelessWidget {
  const WildTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wild Trace',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B4332),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1B4332),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      ),
      home: const SplashScreen(),
      scrollBehavior: const NoGlowScrollBehavior(),
    );
  }
}

// ============================================================================
// CUSTOM SCROLL BEHAVIOR
// ============================================================================
class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();
  
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
