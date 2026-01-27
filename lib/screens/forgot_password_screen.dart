import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/wildtrace_logo.dart';
import '../widgets/custom_button.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false),
                child: const WildTraceLogo(),
              ),
              const SizedBox(height: 24),
              Text(
                'Reset Password',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RECOVERY ACCESS',
                style: GoogleFonts.inter(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.grey[600]),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'FORGOT YOUR PASSWORD? NO PROBLEM. JUST LET US KNOW YOUR EMAIL ADDRESS AND WE WILL EMAIL YOU A PASSWORD RESET LINK.',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey[400], height: 1.6, letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(label: 'EMAIL ADDRESS', controller: _emailController, hintText: 'name@example.com'),
                    const SizedBox(height: 32),
                    CustomButton(text: 'SEND RESET LINK', onPressed: () {}),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                        child: Text('BACK TO SIGN IN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey[500], letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Text('WILDTRACE © 2026', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2.0, color: Colors.grey[400], fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
