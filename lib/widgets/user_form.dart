// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// USER FORM WIDGET - Reusable Form for User Data
// ============================================================================
class UserForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController contactController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  
  final String addressLabel;
  final String contactLabel;
  final bool isPasswordObscure;
  final bool isConfirmPasswordObscure;
  final VoidCallback? onPasswordToggle;
  final VoidCallback? onConfirmPasswordToggle;

  const UserForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.contactController,
    required this.addressController,
    required this.cityController,
    required this.postalCodeController,
    this.addressLabel = 'ADDRESS',
    this.contactLabel = 'CONTACT NUMBER',
    this.passwordController,
    this.confirmPasswordController,
    this.isPasswordObscure = true,
    this.isConfirmPasswordObscure = true,
    this.onPasswordToggle,
    this.onConfirmPasswordToggle,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

// ============================================================================
// USER FORM STATE
// ============================================================================
class _UserFormState extends State<UserForm> {
  Country _selectedCountry = Country.parse('LK');

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        CustomTextField(label: 'FULL NAME', controller: widget.nameController, hintText: 'Pavan'),
        const SizedBox(height: 20),
        CustomTextField(label: 'EMAIL ADDRESS', controller: widget.emailController, hintText: 'name@example.com'),
        const SizedBox(height: 20),
        CustomTextField(
          label: widget.contactLabel, 
          controller: widget.contactController, 
          hintText: '77 123 4567',
          prefix: InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() => _selectedCountry = country);
                },
                countryListTheme: CountryListThemeData(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  textStyle: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black),
                  inputDecoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Country',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedCountry.flagEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    '+${_selectedCountry.phoneCode}', 
                    style: GoogleFonts.inter(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    )
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (widget.passwordController != null && widget.confirmPasswordController != null) ...[
          CustomTextField(label: 'PASSWORD', controller: widget.passwordController!, hintText: '........', isObscure: widget.isPasswordObscure, hasToggle: true, onToggleVisibility: widget.onPasswordToggle),
          const SizedBox(height: 20),
          CustomTextField(label: 'CONFIRM PASSWORD', controller: widget.confirmPasswordController!, hintText: '........', isObscure: widget.isConfirmPasswordObscure, hasToggle: true, onToggleVisibility: widget.onConfirmPasswordToggle),
          const SizedBox(height: 20),
        ],
        CustomTextField(label: widget.addressLabel, controller: widget.addressController, hintText: 'Street address'),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(child: CustomTextField(label: 'CITY', controller: widget.cityController, hintText: 'City')),
            const SizedBox(width: 16),
            Expanded(child: CustomTextField(label: 'POSTAL CODE', controller: widget.postalCodeController, hintText: '10100')),
          ],
        ),
        const SizedBox(height: 20),

        CustomTextField(label: 'COUNTRY', controller: TextEditingController(text: 'Sri Lanka'), hintText: 'Sri Lanka'),
      ],
    );
  }
}
