import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/navigation_provider.dart';
import 'screens/splash_screen.dart';

// Main Application Entry Point
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
    );
  }
}
