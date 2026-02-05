// Imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main_wrapper.dart';
import '../../providers/auth_provider.dart';
import '../widgets/forms/user_form.dart';
import '../widgets/common/wildtrace_logo.dart';
import '../widgets/common/custom_button.dart';
import 'login_screen.dart';
import 'package:quickalert/quickalert.dart';

// Register Screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// Register State
class _RegisterScreenState extends State<RegisterScreen> {
  // State management for user registration inputs
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
  final TextEditingController _countryController = TextEditingController();

  // Build Method
  // Main build method for the registration screen
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
                    child: const WildTraceLogo()
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
                          countryController: _countryController,
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
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.warning,
                                title: 'Mismatch',
                                widget: Text(
                                  'Passwords do not match',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                titleColor: isDarkMode ? Colors.white : Colors.black,
                                confirmBtnText: 'Okay',
                                confirmBtnTextStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
                              // Country might need to be added to register method if supported, 
                              // but for now we ensure it is collected.
                            );
                            
                            if (success && mounted) {
                              Navigator.pushAndRemoveUntil(
                                context, 
                                MaterialPageRoute(builder: (context) => const MainWrapper()), 
                                (route) => false
                              );
                            } else if (mounted) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.error,
                                title: 'Registration Failed',
                                widget: Text(
                                  'Please check your details and try again.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                                titleColor: isDarkMode ? Colors.white : Colors.black,
                                confirmBtnText: 'Okay',
                                confirmBtnTextStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Copyright © 2026 ', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
                      InkWell(
                        onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainWrapper()), (route) => false),
                        child: Text('WILDTRACE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF27AE60)))
                      ),
                      Text('. All Rights Reserved.', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
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
