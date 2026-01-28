// --- Imports ---
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/user_form.dart';
import '../widgets/custom_button.dart';

// --- Screen ---
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

// --- State ---
class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Vinsara Senanayake');
  final TextEditingController _emailController = TextEditingController(text: 'vinsara@example.com');
  final TextEditingController _contactController = TextEditingController(text: '+94 77 123 4567');
  final TextEditingController _addressController = TextEditingController(text: '123 Wild Lane');
  final TextEditingController _cityController = TextEditingController(text: 'Colombo');
  final TextEditingController _postalCodeController = TextEditingController(text: '10110');
  final TextEditingController _currPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confPass = TextEditingController();
  bool _obscureCurrent = true, _obscureNew = true, _obscureConfirm = true;

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9), 
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.transparent,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 20,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildBreadcrumb(),
            const SizedBox(height: 16),
            _buildTitle(textColor),
            const SizedBox(height: 48),
            _buildProfileSection(isDarkMode),
            const SizedBox(height: 40),
            _buildPasswordSection(isDarkMode),
            const SizedBox(height: 40),
            _buildTwoFactorSection(textColor),
            const SizedBox(height: 40),
            _buildSessionsSection(textColor),
            const SizedBox(height: 40),
            _buildDestructiveSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  Widget _buildBreadcrumb() {
    return Text('BACK TO DASHBOARD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey.shade500));
  }
  Widget _buildTitle(Color textColor) {
    return Text('Edit Profile', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: textColor));
  }
  Widget _buildProfileSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1B4332)),
        ),
        const SizedBox(height: 8),
        Text(
          "Update your account's profile information and email address.",
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              UserForm(
                nameController: _nameController, emailController: _emailController,
                contactController: _contactController, addressController: _addressController,
                cityController: _cityController, postalCodeController: _postalCodeController,
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'SAVE', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildPasswordSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Password',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1B4332)),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure your account is using a long, random password to stay secure.',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              CustomTextField(label: 'Current Password', controller: _currPass, hintText: '', isObscure: _obscureCurrent, hasToggle: true, onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent)),
              const SizedBox(height: 20),
              CustomTextField(label: 'New Password', controller: _newPass, hintText: '', isObscure: _obscureNew, hasToggle: true, onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew)),
              const SizedBox(height: 20),
              CustomTextField(label: 'Confirm Password', controller: _confPass, hintText: '', isObscure: _obscureConfirm, hasToggle: true, onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm)),
              const SizedBox(height: 24),
              CustomButton(text: 'SAVE', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildTwoFactorSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Two Factor Authentication',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Add additional security to your account using two factor authentication.',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You have not enabled two factor authentication.', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 12),
              Text("When two factor authentication is enabled, you will be prompted for a secure, random token during authentication.", style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              CustomButton(text: 'ENABLE', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildSessionsSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browser Sessions',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage and log out your active sessions on other browsers and devices.',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manage and log out your active sessions on other browsers and devices.', style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.desktop_windows_outlined, size: 32, color: Colors.grey.shade500),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Windows - Edge', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                      const SizedBox(height: 2),
                      Text('127.0.0.1, This device', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'LOG OUT OTHER BROWSER SESSIONS', onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildDestructiveSection() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delete Account',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1B4332)),
        ),
        const SizedBox(height: 8),
        Text(
          'Permanently delete your account.',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Once your account is deleted, all of its resources and data will be permanently deleted.', style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              CustomButton(text: 'DELETE ACCOUNT', type: CustomButtonType.destructive, onPressed: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
