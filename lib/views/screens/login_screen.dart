import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../main_wrapper.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/navigation_controller.dart';
import 'register_screen.dart';
import '../widgets/common/common_widgets.dart';

import '../../utilities/alert_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Handle user login request
  Future<void> _handleLogin(
    AuthController authProvider,
    bool isDarkMode,
  ) async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      AlertService.showWarning(
        context: context,
        title: 'Missing Details',
        text: 'Please enter your credentials and sign in',
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      AlertService.showWarning(
        context: context,
        title: 'Invalid Email',
        text: 'Please enter a valid email address',
      );
      return;
    }

    try {
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        Provider.of<NavigationController>(context, listen: false).setSelectedIndex(0);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainWrapper()),
          (route) => false,
        );
      } else if (mounted) {
        AlertService.showError(
          context: context,
          title: 'Login Failed',
          text: 'Please check your credentials.',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        AlertService.showError(
          context: context,
          title: 'Login Error',
          text: errorMessage,
        );
      }
    }
  }

  // Build ui for login screen
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
          'Login',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Provider.of<NavigationController>(context, listen: false).setSelectedIndex(0);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainWrapper()),
              (route) => false,
            );
          },
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
                    width: isLandscape ? MediaQuery.of(context).size.width * 0.6 : double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SectionTitle(
                        title: 'SECURE LOGIN',
                        mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                            color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email and password to access your account.',
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
                        ? MediaQuery.of(context).size.width * 0.6
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
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      autofillHints: const [AutofillHints.email],
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
                                      onToggleVisibility: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [AutofillHints.password],
                                      onSubmitted: (_) => _handleLogin(
                                        authProvider,
                                        isDarkMode,
                                      ),
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
                                    autofillHints: const [AutofillHints.email],
                                  ),
                                  const SizedBox(height: 24),
                                  CustomTextField(
                                    label: 'PASSWORD',
                                    controller: _passwordController,
                                    hintText: '........',
                                    isObscure: _obscurePassword,
                                    hasToggle: true,
                                    onToggleVisibility: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [AutofillHints.password],
                                    onSubmitted: (_) =>
                                        _handleLogin(authProvider, isDarkMode),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'SIGN IN',
                          onPressed: () => _handleLogin(authProvider, isDarkMode),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'REGISTER NOW',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  const SizedBox(height: 48),
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
