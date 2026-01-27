import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/user_form.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/section_container.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Profile Input Controllers
  final TextEditingController _nameController = TextEditingController(text: 'Vinsara Senanayake');
  final TextEditingController _emailController = TextEditingController(text: 'vinsara@example.com');
  final TextEditingController _contactController = TextEditingController(text: '+94 77 123 4567');
  final TextEditingController _addressController = TextEditingController(text: '123 Wild Lane');
  final TextEditingController _cityController = TextEditingController(text: 'Colombo');
  final TextEditingController _postalCodeController = TextEditingController(text: '10110');

  // Password Toggle States
  final TextEditingController _currPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confPass = TextEditingController();
  bool _obscureCurrent = true, _obscureNew = true, _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', height: 24, errorBuilder: (_,__,___) => const Icon(Icons.pets, size: 24, color: Colors.orange)),
      ),
      bottomNavigationBar: const WildTraceBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildBreadcrumb(), // Top Hint
            const SizedBox(height: 16),
            _buildTitle(textColor), // Main Heading
            const SizedBox(height: 48),
            _buildProfileSection(isDarkMode), // Account Details
            const SizedBox(height: 40),
            _buildPasswordSection(isDarkMode), // Security
            const SizedBox(height: 40),
            _buildTwoFactorSection(textColor), // Multi-factor Auth
            const SizedBox(height: 40),
            _buildSessionsSection(textColor), // Device Logs
            const SizedBox(height: 40),
            _buildDestructiveSection(), // Delete account
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Text('BACK TO DASHBOARD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey.shade500));
  }

  Widget _buildTitle(Color textColor) {
    return Text('Edit Profile', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: textColor));
  }

  Widget _buildProfileSection(bool isDarkMode) {
    return SectionContainer(
      title: 'Profile Information',
      description: "Update your account's profile information and email address.",
      child: Column(
        children: [
          UserForm(
            nameController: _nameController, emailController: _emailController,
            contactController: _contactController, addressController: _addressController,
            cityController: _cityController, postalCodeController: _postalCodeController,
          ),
          const SizedBox(height: 24),
          _buildActionButton('SAVE', () {}),
        ],
      ),
    );
  }

  Widget _buildPasswordSection(bool isDarkMode) {
    return SectionContainer(
      title: 'Update Password',
      description: 'Ensure your account is using a long, random password to stay secure.',
      child: Column(
        children: [
          CustomTextField(label: 'Current Password', controller: _currPass, hintText: '', isObscure: _obscureCurrent, hasToggle: true, onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent)),
          const SizedBox(height: 20),
          CustomTextField(label: 'New Password', controller: _newPass, hintText: '', isObscure: _obscureNew, hasToggle: true, onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew)),
          const SizedBox(height: 20),
          CustomTextField(label: 'Confirm Password', controller: _confPass, hintText: '', isObscure: _obscureConfirm, hasToggle: true, onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm)),
          const SizedBox(height: 24),
          _buildActionButton('SAVE', () {}),
        ],
      ),
    );
  }

  Widget _buildTwoFactorSection(Color textColor) {
    return SectionContainer(
      title: 'Two Factor Authentication',
      description: 'Add additional security to your account using two factor authentication.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('You have not enabled two factor authentication.', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 12),
          Text("When two factor authentication is enabled, you will be prompted for a secure, random token during authentication.", style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          _buildActionButton('ENABLE', () {}),
        ],
      ),
    );
  }

  Widget _buildSessionsSection(Color textColor) {
    return SectionContainer(
      title: 'Browser Sessions',
      description: 'Manage and log out your active sessions on other browsers and devices.',
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
          _buildActionButton('LOG OUT OTHER BROWSER SESSIONS', () {}),
        ],
      ),
    );
  }

  Widget _buildDestructiveSection() {
    return SectionContainer(
      title: 'Delete Account',
      description: 'Permanently delete your account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Once your account is deleted, all of its resources and data will be permanently deleted.', style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
            child: Text('DELETE ACCOUNT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F2937), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
    );
  }
}
