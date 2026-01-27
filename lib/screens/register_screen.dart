import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'login_screen.dart';

// --- Register Screen ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
              const SizedBox(height: 40),
              // Logo
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(Icons.pets, color: isDarkMode ? Colors.white : const Color(0xFF1B4332), size: 60),
                ),
              ),
              const SizedBox(height: 24),
              // Title
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
                style: GoogleFonts.inter(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              // Register Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name
                    _buildLabel('FULL NAME', isDarkMode),
                    _buildTextField(_nameController, 'Enter your full name', isDarkMode),
                    const SizedBox(height: 20),

                    // Email Address
                    _buildLabel('EMAIL ADDRESS', isDarkMode),
                    _buildTextField(_emailController, 'name@example.com', isDarkMode),
                    const SizedBox(height: 20),
                    
                    // Password & Confirm Password
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('PASSWORD', isDarkMode),
                              _buildPasswordField(_passwordController, '........', _obscurePassword, () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              }, isDarkMode),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('CONFIRM PASSWORD', isDarkMode),
                              _buildPasswordField(_confirmPasswordController, '........', _obscureConfirmPassword, () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              }, isDarkMode),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contact Number
                    _buildLabel('CONTACT NUMBER', isDarkMode),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          ),
                          child: Text('+94', style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : Colors.grey[600])),
                        ),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              hintText: '771234567',
                              hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Address
                    _buildLabel('ADDRESS', isDarkMode),
                    _buildTextField(TextEditingController(), 'Street address, building name, etc.', isDarkMode),
                    const SizedBox(height: 20),

                    // City & Postal Code
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('CITY', isDarkMode),
                              _buildTextField(TextEditingController(), 'Enter your city', isDarkMode),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('POSTAL CODE', isDarkMode),
                              _buildTextField(TextEditingController(), 'e.g. 10100', isDarkMode),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Country
                    _buildLabel('COUNTRY', isDarkMode),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sri Lanka', style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black87)),
                          Text('DEFAULT', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Register Button
                    _buildSubmitButton('COMPLETE REGISTRATION', () {}, isDarkMode),
                    
                    const SizedBox(height: 24),
                    
                    // Link to Login
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'ALREADY REGISTERED? SIGN IN',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Footer
              Text(
                'WILDTRACE © 2026',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  letterSpacing: 2.0,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white60 : Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDarkMode) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, bool obscure, VoidCallback onToggle, bool isDarkMode) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.grey[400]),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey[400],
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String text, VoidCallback onPressed, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.white : const Color(0xFF1B1B1B),
          foregroundColor: isDarkMode ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
