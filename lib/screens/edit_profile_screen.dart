import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/user_form.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Profile Info Controllers
  final TextEditingController _nameController = TextEditingController(text: 'pavan');
  final TextEditingController _emailController = TextEditingController(text: 'pavan@gmail.com');
  final TextEditingController _contactController = TextEditingController(text: '111111111');
  final TextEditingController _addressController = TextEditingController(text: 'safasf');
  final TextEditingController _cityController = TextEditingController(text: 'Saf');
  final TextEditingController _postalCodeController = TextEditingController(text: '11111');

  // Password Update Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();
  
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirmNew = true;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Image.asset(
              'assets/images/logo.png', // Main logo
              height: 24,
              errorBuilder: (_,__,___) => const Icon(Icons.pets, size: 24, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          // Spacer just to center the title logo better if needed, or empty
          const SizedBox(width: 48),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             Text(
              'BACK TO DASHBOARD',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit Profile',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: textColor,
              ),
            ),
            const SizedBox(height: 48),

            // 1. Profile Information
            _buildSectionLayout(
              context,
              title: 'Profile Information',
              description: "Update your account's profile information and email address.",
              child: Column(
                children: [
                  UserForm(
                    nameController: _nameController,
                    emailController: _emailController,
                    contactController: _contactController,
                    addressController: _addressController,
                    cityController: _cityController,
                    postalCodeController: _postalCodeController,
                    // No password controllers passed here -> inputs will be hidden
                  ),
                  const SizedBox(height: 24),
                  _buildSaveButton(isDarkMode),

                ],
              ),
            ),

            const SizedBox(height: 40),

            // 2. Update Password
            _buildSectionLayout(
              context,
              title: 'Update Password',
              description: 'Ensure your account is using a long, random password to stay secure.',
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Current Password',
                    controller: _currentPasswordController,
                    hintText: '',
                    isObscure: _obscureCurrent,
                    hasToggle: true,
                    onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'New Password',
                    controller: _newPasswordController,
                    hintText: '',
                    isObscure: _obscureNew,
                    hasToggle: true,
                    onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Confirm Password',
                    controller: _confirmNewPasswordController,
                    hintText: '',
                    isObscure: _obscureConfirmNew,
                    hasToggle: true,
                    onToggleVisibility: () => setState(() => _obscureConfirmNew = !_obscureConfirmNew),
                  ),
                  const SizedBox(height: 24),
                  _buildSaveButton(isDarkMode),

                ],
              ),
            ),

            const SizedBox(height: 40),

            // 3. Two Factor Authentication
             _buildSectionLayout(
              context,
              title: 'Two Factor Authentication',
              description: 'Add additional security to your account using two factor authentication.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You have not enabled two factor authentication.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "When two factor authentication is enabled, you will be prompted for a secure, random token during authentication. You may retrieve this token from your phone's Google Authenticator application.",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDarkButton('ENABLE', () {}),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 4. Browser Sessions
             _buildSectionLayout(
              context,
              title: 'Browser Sessions',
              description: 'Manage and log out your active sessions on other browsers and devices.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'If necessary, you may log out of all of your other browser sessions across all of your devices. Some of your recent sessions are listed below; however, this list may not be exhaustive. If you feel your account has been compromised, you should also update your password.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.desktop_windows_outlined, size: 32, color: Colors.grey.shade500),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Windows - Edge',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '127.0.0.1, ',
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey.shade500),
                              ),
                              Text(
                                'This device',
                                style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF2ECC71), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDarkButton('LOG OUT OTHER BROWSER SESSIONS', () {}),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. Delete Account
             _buildSectionLayout(
              context,
              title: 'Delete Account',
              description: 'Permanently delete your account.',
              isDestructiveContainer: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Once your account is deleted, all of its resources and data will be permanently deleted. Before deleting your account, please download any data or information that you wish to retain.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'DELETE ACCOUNT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLayout(
    BuildContext context, {
    required String title,
    required String description,
    required Widget child,
    bool isDestructiveContainer = false,
  }) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & Desc
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
        // Card Content
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDarkMode) {
    return _buildDarkButton('SAVE', () {});
  }

  Widget _buildDarkButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
