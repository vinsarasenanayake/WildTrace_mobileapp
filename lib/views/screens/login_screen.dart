// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main_wrapper.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/wildtrace_logo.dart';
import '../widgets/common/custom_button.dart';

// ============================================================================
// LOGIN SCREEN
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ============================================================================
// LOGIN STATE
// ============================================================================
class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainWrapper()), (route) => false),
                    child: const WildTraceLogo(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SIGN IN TO WILDTRACE',
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
                        CustomTextField(label: 'EMAIL ADDRESS', controller: _emailController, hintText: 'name@example.com'),
                        const SizedBox(height: 24),
                        CustomTextField(label: 'PASSWORD', controller: _passwordController, hintText: '........', isObscure: _obscurePassword, hasToggle: true, onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword)),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: authProvider.isLoading ? 'SIGNING IN...' : 'SIGN IN', 
                          onPressed: authProvider.isLoading ? () {} : () async {
                            final success = await authProvider.login(
                              _emailController.text, 
                              _passwordController.text
                            );
                            if (success && mounted) {
                              Navigator.pushAndRemoveUntil(
                                context, 
                                MaterialPageRoute(builder: (context) => const MainWrapper()), 
                                (route) => false
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login failed. Please check your credentials.'))
                              );
                            }
                          }
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                              child: Text('FORGOT PASSWORD?', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                            ),
                            const SizedBox(width: 8),
                            Text('|', style: TextStyle(color: Colors.grey[300])),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                              child: Text('REGISTER NOW', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text('WILDTRACE © 2026', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 2.0, color: Colors.grey[400], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 24),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}



