import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/hardware_controller.dart';
import '../../../utilities/alert_service.dart';
import '../common/common_widgets.dart';

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
  final bool isLandscape;

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
    this.isLandscape = false,
  });

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  Country _selectedCountry = Country.parse('LK');

  Future<void> _detectLocation() async {
    final hw = Provider.of<HardwareController>(context, listen: false);

    try {
      final addressData = await hw.detectLocation();

      if (addressData != null) {
        widget.addressController.text = addressData['address'] ?? '';
        widget.cityController.text = addressData['city'] ?? '';
        widget.postalCodeController.text = addressData['postalCode'] ?? '';
        if (widget.countryController != null) {
          widget.countryController!.text = addressData['country'] ?? '';
        }
      } else {
        if (mounted) {
          AlertService.showError(
            context: context,
            title: 'Detection Failed',
            text:
                'Could not fetch your location. Please check your GPS settings and permissions.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('InternetConnectionError')) {
          AlertService.showError(
            context: context,
            title: 'No Connection',
            text: 'Please connect to the internet to detect your address.',
          );
          return;
        }

        String errorMsg =
            'We couldn\'t detect your location. Please make sure your GPS is turned on and try again.';

        if (e.toString().contains('Timeout') ||
            e.toString().contains('timed out')) {
          errorMsg =
              'Location detection took too long. Please ensure you have a clear signal and try again.';
        }

        AlertService.showWarning(
          context: context,
          title: 'Location Unavailable',
          text: errorMsg,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final nameField = CustomTextField(
      label: 'FULL NAME',
      controller: widget.nameController,
      hintText: 'Full Name',
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
    );

    final emailField = CustomTextField(
      label: 'EMAIL ADDRESS',
      controller: widget.emailController,
      hintText: 'Enter Your Email Address',
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
    );

    final contactField = CustomTextField(
      label: widget.contactLabel,
      controller: widget.contactController,
      hintText: '77 123 4567',
      textInputAction: TextInputAction.next,
      maxLength: 9,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      prefix: InkWell(
        onTap: () {
          showCountryPicker(
            context: context,
            showPhoneCode: true,
            onSelect: (Country country) {
              setState(() => _selectedCountry = country);
            },
            countryListTheme: CountryListThemeData(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              textStyle: GoogleFonts.inter(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              inputDecoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Country',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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
              Text(
                _selectedCountry.flagEmoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Text(
                '+${_selectedCountry.phoneCode}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.withAlpha((0.2 * 255).round()),
              ),
            ],
          ),
        ),
      ),
    );

    Widget? passField;
    Widget? confirmField;
    if (widget.passwordController != null &&
        widget.confirmPasswordController != null) {
      passField = CustomTextField(
        label: 'PASSWORD',
        controller: widget.passwordController!,
        hintText: '........',
        isObscure: widget.isPasswordObscure,
        hasToggle: true,
        onToggleVisibility: widget.onPasswordToggle,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.password],
      );
      confirmField = CustomTextField(
        label: 'CONFIRM PASSWORD',
        controller: widget.confirmPasswordController!,
        hintText: '........',
        isObscure: widget.isConfirmPasswordObscure,
        hasToggle: true,
        onToggleVisibility: widget.onConfirmPasswordToggle,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.password],
      );
    }

    final addressField = Consumer<HardwareController>(
      builder: (context, hw, _) => CustomTextField(
        label: widget.addressLabel,
        controller: widget.addressController,
        hintText: '',
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.addressCityAndState],
        suffix: TextButton(
          onPressed: hw.isDetectingLocation ? null : _detectLocation,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: hw.isDetectingLocation
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF27AE60),
                  ),
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
    );

    final cityField = CustomTextField(
      label: 'CITY',
      controller: widget.cityController,
      hintText: '',
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.addressCity],
    );

    final postalField = CustomTextField(
      label: 'POSTAL CODE',
      controller: widget.postalCodeController,
      hintText: '',
      textInputAction: widget.countryController == null
          ? TextInputAction.done
          : TextInputAction.next,
      onSubmitted: widget.countryController == null ? widget.onSubmitted : null,
      autofillHints: const [AutofillHints.postalCode],
    );

    Widget? countryField;
    if (widget.countryController != null) {
      countryField = GestureDetector(
        onTap: () {
          showCountryPicker(
            context: context,
            onSelect: (Country country) {
              setState(() {
                widget.countryController!.text = country.name;
              });
            },
            countryListTheme: CountryListThemeData(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              textStyle: GoogleFonts.inter(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              inputDecoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search Country',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white30 : Colors.black26,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : Colors.grey.shade100,
              ),
            ),
          );
        },
        child: AbsorbPointer(
          child: CustomTextField(
            label: 'COUNTRY',
            controller: widget.countryController!,
            hintText: '',
            suffix: const Icon(Icons.keyboard_arrow_down_rounded),
            textInputAction: TextInputAction.done,
            onSubmitted: widget.onSubmitted,
            autofillHints: const [AutofillHints.countryName],
          ),
        ),
      );
    }

    Widget row(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );

    return AutofillGroup(
      child: Column(
        children: [
          widget.isLandscape
              ? row(nameField, emailField)
              : Column(
                  children: [nameField, const SizedBox(height: 20), emailField],
                ),
          const SizedBox(height: 20),

          contactField,
          const SizedBox(height: 20),

          if (passField != null && confirmField != null) ...[
            widget.isLandscape
                ? row(passField, confirmField)
                : Column(
                    children: [
                      passField,
                      const SizedBox(height: 20),
                      confirmField,
                    ],
                  ),
            const SizedBox(height: 20),
          ],

          widget.isLandscape
              ? row(addressField, cityField)
              : Column(
                  children: [
                    addressField,
                    const SizedBox(height: 20),
                    row(cityField, postalField),
                  ],
                ),

          const SizedBox(height: 20),

          if (widget.isLandscape) ...[
            row(postalField, countryField ?? const SizedBox()),
          ] else ...[
            if (countryField != null) countryField,
          ],
        ],
      ),
    );
  }
}
