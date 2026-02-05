// ============================================================================
// IMPORTS
// ============================================================================
import 'package:flutter/material.dart';
import '../common/custom_text_field.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wild_trace/services/location_service.dart';
import 'package:quickalert/quickalert.dart';

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
  final TextEditingController? countryController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  
  final String addressLabel;
  final String contactLabel;
  final bool isPasswordObscure;
  final bool isConfirmPasswordObscure;
  final VoidCallback? onPasswordToggle;
  final VoidCallback? onConfirmPasswordToggle;
  final ValueChanged<String>? onSubmitted;

  const UserForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.contactController,
    required this.addressController,
    required this.cityController,
    required this.postalCodeController,
    this.countryController,
    this.addressLabel = 'ADDRESS',
    this.contactLabel = 'CONTACT NUMBER',
    this.passwordController,
    this.confirmPasswordController,
    this.isPasswordObscure = true,
    this.isConfirmPasswordObscure = true,
    this.onPasswordToggle,
    this.onConfirmPasswordToggle,
    this.onSubmitted,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

// ============================================================================
// USER FORM STATE
// ============================================================================
class _UserFormState extends State<UserForm> {
  Country _selectedCountry = Country.parse('LK');
  final LocationService _locationService = LocationService();
  bool _isDetecting = false;

  Future<void> _detectLocation() async {
    setState(() => _isDetecting = true);
    
    try {
      // Wrap the entire process in a hard 45-second timeout
      final addressData = await _locationService.getCurrentAddress().timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw Exception('Location request timed out. Please ensure GPS is active and a location point is set in emulator settings.'),
      );
      
      if (addressData != null) {
        widget.addressController.text = addressData['address'] ?? '';
        widget.cityController.text = addressData['city'] ?? '';
        widget.postalCodeController.text = addressData['postalCode'] ?? '';
        if (widget.countryController != null) {
          widget.countryController!.text = addressData['country'] ?? '';
        }
      } else {
        if (mounted) {
           QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Detection Failed',
            text: 'Could not fetch your location. Please check your GPS settings and permissions.',
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            titleColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            textColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            confirmBtnText: 'Okay',
            confirmBtnTextStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          );
        }
      }
    } catch (e) {
       if (mounted) {
          String errorMsg = 'We couldn\'t detect your location. Please make sure your GPS is turned on and try again.';
          
          if (e.toString().contains('Timeout') || e.toString().contains('timed out')) {
            errorMsg = 'Location detection took too long. Please ensure you have a clear signal and try again.';
          }
          
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning, // Changed to warning for a less "scary" look
            title: 'Location Unavailable',
            text: errorMsg,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            titleColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            textColor: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
            confirmBtnText: 'Okay',
            confirmBtnTextStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
          );
       }
    } finally {
      if (mounted) {
        setState(() => _isDetecting = false);
      }
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        CustomTextField(
          label: 'FULL NAME', 
          controller: widget.nameController, 
          hintText: 'Full Name',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'EMAIL ADDRESS', 
          controller: widget.emailController, 
          hintText: 'Enter Your Email Address',
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: widget.contactLabel, 
          controller: widget.contactController, 
          hintText: '77 123 4567',
          textInputAction: TextInputAction.next,
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
          CustomTextField(
            label: 'PASSWORD', 
            controller: widget.passwordController!, 
            hintText: '........', 
            isObscure: widget.isPasswordObscure, 
            hasToggle: true, 
            onToggleVisibility: widget.onPasswordToggle,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'CONFIRM PASSWORD', 
            controller: widget.confirmPasswordController!, 
            hintText: '........', 
            isObscure: widget.isConfirmPasswordObscure, 
            hasToggle: true, 
            onToggleVisibility: widget.onConfirmPasswordToggle,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
        ],
        CustomTextField(
          label: widget.addressLabel, 
          controller: widget.addressController, 
          hintText: 'Street address',
          textInputAction: TextInputAction.next,
          suffix: TextButton(
            onPressed: _isDetecting ? null : _detectLocation,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: _isDetecting 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF27AE60))
                )
              : Text(
                  'DETECT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF27AE60),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'CITY', 
                controller: widget.cityController, 
                hintText: 'City',
                textInputAction: TextInputAction.next,
              )
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'POSTAL CODE', 
                controller: widget.postalCodeController, 
                hintText: '10100',
                textInputAction: widget.countryController == null ? TextInputAction.done : TextInputAction.next,
                onSubmitted: widget.countryController == null ? widget.onSubmitted : null,
              )
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (widget.countryController != null)
          GestureDetector(
            onTap: () {
               showCountryPicker(
                context: context,
                onSelect: (Country country) {
                  setState(() {
                     widget.countryController!.text = country.name;
                  });
                },
                countryListTheme: CountryListThemeData(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  textStyle: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black),
                  inputDecoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search Country',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black26),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                  ),
                ),
              );
            },
            child: AbsorbPointer(
              child: CustomTextField(
                label: 'COUNTRY', 
                controller: widget.countryController!, 
                hintText: 'Select Country',
                suffix: const Icon(Icons.keyboard_arrow_down_rounded),
                textInputAction: TextInputAction.done,
                onSubmitted: widget.onSubmitted,
              ),
            ),
          )
        else 
           const SizedBox.shrink(),
      ],
    );
  }
}

