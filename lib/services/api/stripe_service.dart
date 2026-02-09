import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../utilities/alert_service.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  // Process payment flow
  Future<void> makePayment({
    required double amount,
    required String currency,
    required BuildContext context,
    required Future<void> Function() onSuccess,
  }) async {
    try {
      // create payment intent
      final paymentIntent = await _createPaymentIntent(
        (amount * 100).toInt().toString(),
        currency,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          style: Theme.of(context).brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          merchantDisplayName: 'WildTrace',
        ),
      );

      await _displayPaymentSheet(onSuccess);
    } on StripeException catch (e) {
      if (context.mounted) {
        if (e.error.code == FailureCode.Canceled) {
          AlertService.showInfo(
            context: context,
            title: 'Payment Canceled',
            text: 'You have canceled the payment process.',
          );
        } else {
          AlertService.showError(
            context: context,
            title: 'Payment Failed',
            text: e.error.localizedMessage ?? 'An error occurred during payment.',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        final errorMessage = e.toString();
        String userMessage = errorMessage;
        
        if (errorMessage.contains('SocketException') || 
            errorMessage.contains('Failed host lookup') || 
            errorMessage.contains('ClientException')) {
          userMessage = 'It looks like you\'re offline. Please check your internet connection to complete your payment.';
        }

        AlertService.showError(
          context: context,
          title: 'Connection Error',
          text: userMessage,
        );
      }
    }
  }

  Future<void> _displayPaymentSheet(Future<void> Function() onSuccess) async {
    await Stripe.instance.presentPaymentSheet();
    await onSuccess();
  }

  // Create a payment intent with Stripe API
  Future<Map<String, dynamic>> _createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${(dotenv.env['STRIPE_SECRET'] ?? '').trim()}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );
      
      final jsonResponse = json.decode(response.body);
      
      if (response.statusCode != 200) {
        final errorMsg = jsonResponse['error']?['message'] ?? 'Failed to create payment intent';
        if (errorMsg.toString().contains('Invalid API Key')) {
          throw Exception('Invalid Stripe Secret Key in .env file. Please check your configuration.');
        }
        throw Exception(errorMsg);
      }
      
      return jsonResponse;
    } catch (e) {
      rethrow;
    }
  }
}
