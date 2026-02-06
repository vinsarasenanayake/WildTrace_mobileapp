import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/forms/user_form.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/wildtrace_logo.dart';
import 'package:quickalert/quickalert.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';

// edit profile screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // form field controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  
  // password modification controllers
  final TextEditingController _currPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confPass = TextEditingController();
  bool _obscureCurrent = true, _obscureNew = true, _obscureConfirm = true;

  // populates controllers with existing user data
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController(text: user?.contactNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }
  
  // disposes all input controllers
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _currPass.dispose();
    _newPass.dispose();
    _confPass.dispose();
    super.dispose();
  }

  // processes profile detail updates
  Future<void> _handleUpdateProfile(AuthProvider authProvider) async {
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      final updatedUser = UserModel(
        id: currentUser.id,
        name: _nameController.text,
        email: _emailController.text,
        contactNumber: _contactController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
        country: _countryController.text,
      );
      
      final success = await authProvider.updateProfile(updatedUser);
      if (mounted) {
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        QuickAlert.show(
          context: context,
          type: success ? QuickAlertType.success : QuickAlertType.error,
          title: success ? 'Profile Updated' : 'Update Failed',
          text: success ? 'Profile updated successfully' : 'Failed to update profile',
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          titleColor: isDarkMode ? Colors.white : Colors.black,
          textColor: isDarkMode ? Colors.white70 : Colors.black87,
        );
      }
    }
  }

  // builds the main screen architecture
  @override
  Widget build(BuildContext context) {
    // detects theme and device orientation
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9), 
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const WildTraceLogo(height: 40),
        centerTitle: true,
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
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            left: false,
            right: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  width: isLandscape ? MediaQuery.of(context).size.width * 0.7 : null,
                  child: Column(
                    children: [
                      // navigation indicators
                      _buildBreadcrumb(),
                      const SizedBox(height: 16),
                      _buildTitle(textColor),
                      const SizedBox(height: 48),
                      // segmented setting sections
                      _buildProfileSection(isDarkMode, authProvider, isLandscape),
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
              ),
            ),
          );
        }
      ),
    );
  }

  // builds the contextual path indicator
  Widget _buildBreadcrumb() {
    return Text('BACK TO DASHBOARD', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey.shade500));
  }

  // builds the page header title
  Widget _buildTitle(Color textColor) {
    return Text('Edit Profile', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: textColor));
  }
  
  // builds the user info modification forms
  Widget _buildProfileSection(bool isDarkMode, AuthProvider authProvider, bool isLandscape) {
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
                countryController: _countryController,
                onSubmitted: (_) => _handleUpdateProfile(authProvider),
                isLandscape: isLandscape,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: authProvider.isLoading ? 'SAVING...' : 'SAVE', 
                onPressed: authProvider.isLoading ? () {} : () => _handleUpdateProfile(authProvider)
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // builds the password management interface
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
               CustomTextField(
                label: 'Current Password', 
                controller: _currPass, 
                hintText: '', 
                isObscure: _obscureCurrent, 
                hasToggle: true, 
                onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'New Password', 
                controller: _newPass, 
                hintText: '', 
                isObscure: _obscureNew, 
                hasToggle: true, 
                onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Confirm Password', 
                controller: _confPass, 
                hintText: '', 
                isObscure: _obscureConfirm, 
                hasToggle: true, 
                onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                   final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.info,
                      title: 'Info',
                      text: 'Password update simulated',
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      titleColor: isDarkMode ? Colors.white : Colors.black,
                      textColor: isDarkMode ? Colors.white70 : Colors.black87,
                    );
                },
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'SAVE', onPressed: () {
                final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                QuickAlert.show(
                  context: context,
                  type: QuickAlertType.info,
                  title: 'Info',
                  text: 'Password update simulated',
                  backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  titleColor: isDarkMode ? Colors.white : Colors.black,
                  textColor: isDarkMode ? Colors.white70 : Colors.black87,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // builds the security configuration area
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

  // builds the active session tracking summary
  Widget _buildSessionsSection(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // session management header
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
              // active device indicator
              Row(
                children: [
                  Icon(Icons.desktop_windows_outlined, size: 32, color: Colors.grey.shade500),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Windows - Edge', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                      const SizedBox(height: 2),
                      Text('127.0.0.1, This device', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF27AE60), fontWeight: FontWeight.bold)),
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

  // builds the danger zone account removal area
  Widget _buildDestructiveSection() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // destructive action header
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
              // initiates deletion with validity checks
              CustomButton(
                text: 'DELETE ACCOUNT', 
                type: CustomButtonType.destructive, 
                onPressed: () {
                  final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
                  final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                  
                  // verifies if there are pending orders before providing deletion option
                  final hasOngoingOrders = ordersProvider.orders.any((order) => 
                    order.status == OrderStatus.paid || 
                    order.status == OrderStatus.processing || 
                    order.status == OrderStatus.shipped
                  );

                  if (hasOngoingOrders) {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: 'Cannot Delete Account',
                      text: 'You have ongoing orders that are being processed or shipped. Please wait until they are delivered or resolved before deleting your account.',
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      titleColor: isDarkMode ? Colors.white : Colors.black,
                      textColor: isDarkMode ? Colors.white70 : Colors.black87,
                      showConfirmBtn: false,
                      widget: Column(
                        children: [
                          SizedBox(height: isLandscape ? 8 : 24),
                          CustomButton(
                            text: 'OKAY',
                            fontSize: 12,
                            verticalPadding: isLandscape ? 10 : 16,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // requests final confirmation
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      title: 'Are you sure?',
                      text: 'Once your account is deleted, all of its resources and data will be permanently deleted.',
                      confirmBtnText: 'Delete',
                      cancelBtnText: 'Cancel',
                      confirmBtnColor: Colors.red,
                      confirmBtnTextStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      cancelBtnTextStyle: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                      onConfirmBtnTap: () {
                        // restricted action notification
                        Navigator.pop(context);
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.info,
                          title: 'Action Restricted',
                          text: 'Account deletion is currently limited for security. Please contact support.',
                          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          titleColor: isDarkMode ? Colors.white : Colors.black,
                          textColor: isDarkMode ? Colors.white70 : Colors.black87,
                          showConfirmBtn: false,
                          widget: Column(
                            children: [
                              SizedBox(height: isLandscape ? 8 : 24),
                              CustomButton(
                                text: 'OKAY',
                                fontSize: 12,
                                verticalPadding: isLandscape ? 10 : 16,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      titleColor: isDarkMode ? Colors.white : Colors.black,
                      textColor: isDarkMode ? Colors.white70 : Colors.black87,
                    );
                  }
                }
              ),
            ],
          ),
        ),
      ],
    );
  }
}



