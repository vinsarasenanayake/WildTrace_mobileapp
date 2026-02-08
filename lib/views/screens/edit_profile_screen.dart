import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/orders_controller.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/forms/form_widgets.dart';

import '../../utilities/alert_service.dart';

// edit profile screen
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  // password controllers
  final TextEditingController _currPass = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confPass = TextEditingController();
  bool _obscureCurrent = true, _obscureNew = true, _obscureConfirm = true;

  // init state
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController(text: user?.contactNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _postalCodeController = TextEditingController(text: user?.postalCode ?? '');
    _countryController = TextEditingController(text: user?.country ?? '');
  }

  // dispose
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

  // updates profile
  Future<void> _handleUpdateProfile(AuthController authProvider) async {
    // hide keyboard
    FocusScope.of(context).unfocus();

    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    // validation
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {

      AlertService.showWarning(
        context: context,
        title: 'Missing Info',
        text: 'Name and Email cannot be empty',
      );
      return;
    }

    // email check
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text)) {

      AlertService.showWarning(
        context: context,
        title: 'Invalid Email',
        text: 'Please enter a valid email address',
      );
      return;
    }

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

    try {
      final success = await authProvider.updateProfile(updatedUser);
      if (mounted) {

        if (success) {
          AlertService.showSuccess(
            context: context,
            title: 'Profile Updated',
            text: 'Profile updated successfully',
          );
        } else {
          AlertService.showError(
            context: context,
            title: 'Update Failed',
            text: 'Failed to update profile',
          );
        }
      }
    } catch (e) {
      if (mounted) {

        String errorMessage = e.toString().replaceAll('Exception: ', '');
        AlertService.showError(
          context: context,
          title: 'Update Error',
          text: errorMessage,
        );
      }
    }
  }

  // builds screen
  @override
  Widget build(BuildContext context) {
    // theme data
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.black
          : const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: isDarkMode
            ? Colors.black
            : const Color(0xFFF9FBF9),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: textColor,
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
              color: textColor,
              size: 20,
            ),
          ),
        ),
      ),
      body: Consumer<AuthController>(
        builder: (context, authProvider, child) {
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.7
                      : null,
                  child: Column(
                    children: [
                      // logo
                      const SizedBox(height: 16),
                      const WildTraceLogo(height: 80),
                      const SizedBox(height: 48),
                      // setting sections
                      _buildProfileSection(
                        isDarkMode,
                        authProvider,
                        isLandscape,
                      ),
                      const SizedBox(height: 40),
                      _buildPasswordSection(isDarkMode, authProvider),
                      const SizedBox(height: 40),
                      _buildDeleteAccountSection(isDarkMode, authProvider),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }



  // builds profile section
  Widget _buildProfileSection(
    bool isDarkMode,
    AuthController authProvider,
    bool isLandscape,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Information',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Update your account's profile information and email address.",
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              UserForm(
                nameController: _nameController,
                emailController: _emailController,
                contactController: _contactController,
                addressController: _addressController,
                cityController: _cityController,
                postalCodeController: _postalCodeController,
                countryController: _countryController,
                onSubmitted: (_) => _handleUpdateProfile(authProvider),
                isLandscape: isLandscape,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'SAVE',
                onPressed: () => _handleUpdateProfile(authProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // builds password section
  Widget _buildPasswordSection(bool isDarkMode, AuthController authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Password',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ensure your account is using a long, random password to stay secure.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              CustomTextField(
                label: 'Current Password',
                controller: _currPass,
                hintText: '',
                isObscure: _obscureCurrent,
                hasToggle: true,
                onToggleVisibility: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'New Password',
                controller: _newPass,
                hintText: '',
                isObscure: _obscureNew,
                hasToggle: true,
                onToggleVisibility: () =>
                    setState(() => _obscureNew = !_obscureNew),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Confirm Password',
                controller: _confPass,
                hintText: '',
                isObscure: _obscureConfirm,
                hasToggle: true,
                onToggleVisibility: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) {

                  AlertService.showInfo(
                    context: context,
                    title: 'Info',
                    text: 'Password update simulated',
                  );
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'SAVE',
                onPressed: () async {
                        if (_newPass.text != _confPass.text) {

                          AlertService.showWarning(
                            context: context,
                            title: 'Mismatch',
                            text: 'Passwords do not match',
                          );
                          return;
                        }

                        final success = await authProvider.updatePassword(
                          _currPass.text,
                          _newPass.text,
                        );
                        if (mounted) {

                          if (success) {
                            AlertService.showSuccess(
                              context: context,
                              title: 'Security Updated',
                              text: 'Management of your credentials has been secured.',
                            );
                          } else {
                            AlertService.showError(
                              context: context,
                              title: 'Update Failed',
                              text: 'Failed to update credentials.',
                            );
                          }
                          if (success) {
                            _currPass.clear();
                            _newPass.clear();
                            _confPass.clear();
                          }
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // builds delete section
  Widget _buildDeleteAccountSection(bool isDarkMode, AuthController authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delete Account',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE11D48),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This action is irreversible. All your data will be permanently removed.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE11D48).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              CustomButton(
                text: 'DELETE ACCOUNT',
                backgroundColor: const Color(0xFFE11D48),
                onPressed: () => _handleDeleteAccount(authProvider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleDeleteAccount(AuthController authProvider) async {
    final ordersProvider = Provider.of<OrdersController>(context, listen: false);
    
    // check constraints
    if (authProvider.currentUser != null && authProvider.token != null) {
       // We force a refresh to be safe, or just rely on existing state if recent?
       // Better to refresh to avoid stale data allowing deletion when it shouldn't.
       // But loadOrders might be heavy. Let's assume state is relatively fresh or empty means not loaded.
       if (ordersProvider.orders.isEmpty) {
           await ordersProvider.loadOrders(authProvider.currentUser!.id, authProvider.token!);
       }
    }
    
    final orders = ordersProvider.orders;
    bool canDelete = true;
    
    // check orders
    for (var order in orders) {
       // check if paid
       bool isPaid = order.status == OrderStatus.paid || 
                     order.status == OrderStatus.processing || 
                     order.status == OrderStatus.shipped ||
                     order.status == OrderStatus.delivered; // Delivered counts as paid history
       
       if (isPaid) {
          // block if future delivery
          
          final DateTime now = DateTime.now();
          // Use estimatedDeliveryDate, default to orderDate + 7 days if null (fallback logic)
          final DateTime estimated = order.estimatedDeliveryDate ?? order.orderDate.add(const Duration(days: 7));
          
          if (estimated.isAfter(now)) {
             // Future delivery -> Block
             canDelete = false;
             break;
          }
       }
       // Pending/Cancelled/Declined are ignored (can delete)
    }

    if (!canDelete) {
      if (mounted) {
        AlertService.showError(
          context: context,
          title: 'Cannot Delete Account',
          text: 'You have active paid orders pending delivery. Please wait until they are delivered.',
        );
      }
      return;
    }

    if (mounted) {
      AlertService.showConfirmation(
        context: context,
        title: 'Delete Account?',
        text: 'Are you sure you want to permanently delete your account?',
        confirmBtnText: 'DELETE',
        confirmBtnColor: const Color(0xFFE11D48),
        onConfirm: () async {
          Navigator.pop(context); // Close dialog
          
          // logout
          await authProvider.logout();
          
          if (mounted) {
            // Pop all routes and go to main wrapper (which defaults to Home/Login)
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      );
    }
  }
}
