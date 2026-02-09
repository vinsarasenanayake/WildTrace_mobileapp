import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main_wrapper.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/forms/form_widgets.dart';
import '../widgets/common/common_widgets.dart';
import 'login_screen.dart';
import '../../utilities/alert_service.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Dispose controllers
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Handle user registration request
  Future<void> _handleRegister(
    AuthController authProvider,
    bool isDarkMode,
  ) async {
    FocusScope.of(context).unfocus();

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      AlertService.showWarning(
        context: context,
        title: 'Missing Info',
        text: 'Please fill in all required fields (Name, Email, Password)',
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      AlertService.showWarning(
        context: context,
        title: 'Invalid Email',
        text: 'Please enter a valid email address',
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      AlertService.showWarning(
        context: context,
        title: 'Mismatch',
        text: 'Passwords do not match',
      );
      return;
    }

    try {
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
        await AlertService.showSuccess(
          context: context,
          title: 'Registration Successful',
          text: 'Account created! Please sign in to continue.',
          confirmBtnText: 'Go to Login',
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        AlertService.showError(
          context: context,
          title: 'Registration Error',
          text: errorMessage,
        );
      }
    }
  }

  // Build ui for register screen
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Register',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
              size: 20,
            ),
          ),
        ),
      ),
      body: SafeArea(
        left: false,
        right: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Consumer<AuthController>(
            builder: (context, authProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const WildTraceLogo(height: 80),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: isLandscape ? MediaQuery.of(context).size.width * 0.7 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SectionTitle(
                          title: 'NEW ACCOUNT',
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join WildTrace',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your account to start your journey.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: isLandscape
                        ? MediaQuery.of(context).size.width * 0.7
                        : null,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.05 * 255).round()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserForm(
                          isLandscape: isLandscape,
                          nameController: _nameController,
                          emailController: _emailController,
                          contactController: _contactController,
                          addressController: _addressController,
                          cityController: _cityController,
                          postalCodeController: _postalCodeController,
                          countryController: _countryController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          isPasswordObscure: _obscurePassword,
                          isConfirmPasswordObscure: _obscureConfirmPassword,
                          onPasswordToggle: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          onConfirmPasswordToggle: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                          onSubmitted: (_) =>
                              _handleRegister(authProvider, isDarkMode),
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'COMPLETE REGISTRATION',
                          onPressed: () => _handleRegister(authProvider, isDarkMode),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Copyright © ${DateTime.now().year} ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainWrapper(),
                          ),
                          (route) => false,
                        ),
                        child: Text(
                          'WILDTRACE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF27AE60),
                          ),
                        ),
                      ),
                      Text(
                        '. All Rights Reserved.',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
