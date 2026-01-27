import 'package:flutter/material.dart';
import 'custom_text_field.dart';
class PaymentForm extends StatelessWidget {
  final TextEditingController cardNumberController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final TextEditingController holderNameController;

  const PaymentForm({
    super.key,
    required this.cardNumberController,
    required this.expiryController,
    required this.cvvController,
    required this.holderNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Card Number',
          controller: cardNumberController,
          hintText: '0000 0000 0000 0000',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Expiry',
                controller: expiryController,
                hintText: 'MM/YY',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'CVV',
                controller: cvvController,
                hintText: '123',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Cardholder Name',
          controller: holderNameController,
          hintText: 'FULL NAME',
        ),
      ],
    );
  }
}
