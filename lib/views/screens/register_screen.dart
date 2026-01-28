// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main_wrapper.dart';
import '../../providers/auth_provider.dart';
import '../widgets/forms/user_form.dart';
import '../widgets/common/wildtrace_logo.dart';
import '../widgets/common/custom_button.dart';
import 'login_screen.dart';

// ============================================================================
// REGISTER SCREEN
// ============================================================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// ============================================================================
// REGISTER STATE
// ============================================================================
class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

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
                    'Join WildTrace',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CREATE YOUR ACCOUNT',
                    style: GoogleFonts.inter(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
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
                        UserForm(
                          nameController: _nameController, emailController: _emailController,
                          contactController: _contactController, addressController: _addressController,
                          cityController: _cityController, postalCodeController: _postalCodeController,
                          passwordController: _passwordController, confirmPasswordController: _confirmPasswordController,
                          isPasswordObscure: _obscurePassword, isConfirmPasswordObscure: _obscureConfirmPassword,
                          onPasswordToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          onConfirmPasswordToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: authProvider.isLoading ? 'CREATING ACCOUNT...' : 'COMPLETE REGISTRATION', 
                          onPressed: authProvider.isLoading ? () {} : () async {
                            if (_passwordController.text != _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Passwords do not match'))
                              );
                              return;
                            }
                            
                            final success = await authProvider.register(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              contactNumber: _contactController.text,
                              address: _addressController.text,
                              city: _cityController.text,
                              postalCode: _postalCodeController.text,
                            );
                            
                            if (success && mounted) {
                              Navigator.pushAndRemoveUntil(
                                context, 
                                MaterialPageRoute(builder: (context) => const MainWrapper()), 
                                (route) => false
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registration failed. Please try again.'))
                              );
                            }
                          }
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                            child: Text(
                              'ALREADY REGISTERED? SIGN IN',
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
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



