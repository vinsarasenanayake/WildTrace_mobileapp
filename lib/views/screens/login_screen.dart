import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main_wrapper.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/wildtrace_logo.dart';
import '../widgets/common/custom_button.dart';
import 'package:quickalert/quickalert.dart';

// user login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // UI state for credential visibility
  bool _obscurePassword = true;
  // controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // manages the authentication submission process
  Future<void> _handleLogin(AuthController authProvider, bool isDarkMode) async {
    // validates that both fields are populated
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Missing Details',
        widget: Text(
          'Please enter your credentials and sign in',
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
    
    try {
      // attempts authentication via the provider
      final success = await authProvider.login(
        _emailController.text, 
        _passwordController.text
      );
      // navigates to main platform upon success
      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => MainWrapper()), 
          (route) => false
        );
      } else if (mounted) {
        // handles generic authentication failure
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Login Failed',
          text: 'Please check your credentials.',
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          titleColor: isDarkMode ? Colors.white : Colors.black,
          textColor: isDarkMode ? Colors.white70 : Colors.black87,
          confirmBtnText: 'Okay',
          confirmBtnTextStyle: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    } catch (e) {
      // provides granular error feedback from the backend
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Login Error',
          text: errorMessage,
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          titleColor: isDarkMode ? Colors.white : Colors.black,
          textColor: isDarkMode ? Colors.white70 : Colors.black87,
          confirmBtnText: 'Okay',
          confirmBtnTextStyle: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        );
      }
    }
  }

  // builds the visual login workflow
  @override
  Widget build(BuildContext context) {
    // theme and adaptive layout detection
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        // session exit navigation
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
                  const SizedBox(height: 40),
                  // platform branding navigation
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainWrapper()), (route) => false),
                    child: const WildTraceLogo()
                  ),
                  const SizedBox(height: 24),
                  // page identification
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
                  // credentials input container
                  Container(
                    width: isLandscape ? MediaQuery.of(context).size.width * 0.6 : null, 
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // adapts input field layout based on screen orientation
                        isLandscape
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'EMAIL ADDRESS', 
                                    controller: _emailController, 
                                    hintText: 'name@example.com',
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'PASSWORD', 
                                    controller: _passwordController, 
                                    hintText: '........', 
                                    isObscure: _obscurePassword, 
                                    hasToggle: true, 
                                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _handleLogin(authProvider, isDarkMode),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                CustomTextField(
                                  label: 'EMAIL ADDRESS', 
                                  controller: _emailController, 
                                  hintText: 'name@example.com',
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 24),
                                CustomTextField(
                                  label: 'PASSWORD', 
                                  controller: _passwordController, 
                                  hintText: '........', 
                                  isObscure: _obscurePassword, 
                                  hasToggle: true, 
                                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _handleLogin(authProvider, isDarkMode),
                                ),
                              ],
                            ),
                        const SizedBox(height: 32),
                        // main action trigger with loading state feedback
                        CustomButton(
                          text: authProvider.isLoading ? 'SIGNING IN...' : 'SIGN IN', 
                          onPressed: authProvider.isLoading ? () {} : () => _handleLogin(authProvider, isDarkMode)
                        ),
                        const SizedBox(height: 24),
                        // secondary navigation options
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
                  // branding and copyright attribution
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Copyright © 2026 ', style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade600)),
                      InkWell(
                        onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainWrapper()), (route) => false),
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

