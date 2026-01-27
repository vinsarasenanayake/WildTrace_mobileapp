import 'package:flutter/material.dart';
import 'custom_text_field.dart';

// Reusable user form structure
class UserForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController contactController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  
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
    this.passwordController,
    this.confirmPasswordController,
    this.isPasswordObscure = true,
    this.isConfirmPasswordObscure = true,
    this.onPasswordToggle,
    this.onConfirmPasswordToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'FULL NAME',
          controller: nameController,
          hintText: 'Enter your full name',
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'EMAIL ADDRESS',
          controller: emailController,
          hintText: 'name@example.com',
        ),
        const SizedBox(height: 20),
        
        // Optional Password Section
        if (passwordController != null && confirmPasswordController != null) ...[
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'PASSWORD',
                  controller: passwordController!,
                  hintText: '........',
                  isObscure: isPasswordObscure,
                  hasToggle: true,
                  onToggleVisibility: onPasswordToggle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'CONFIRM PASSWORD',
                  controller: confirmPasswordController!,
                  hintText: '........',
                  isObscure: isConfirmPasswordObscure,
                  hasToggle: true,
                  onToggleVisibility: onConfirmPasswordToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        CustomTextField(
          label: 'CONTACT NUMBER',
          controller: contactController,
          hintText: '771234567',
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'ADDRESS',
          controller: addressController,
          hintText: 'Street address, building name, etc.',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'CITY',
                controller: cityController,
                hintText: 'Enter your city',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'POSTAL CODE',
                controller: postalCodeController,
                hintText: 'e.g. 10100',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Country Dropdown Placeholder (Reusing style logic, simplified for now)
        CustomTextField(
          label: 'COUNTRY',
          controller: TextEditingController(text: 'Sri Lanka'), // Static for now as per original
          hintText: 'Sri Lanka',
        ), 
      ],
    );
  }
}
