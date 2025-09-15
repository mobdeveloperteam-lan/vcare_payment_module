import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

typedef PaymentResultCallback = void Function(String result);

class VcarePaymentModule {
  static const MethodChannel _channel = MethodChannel('vcare_payment_module');
  static String? _stripeSecretKey;

  /// Initialize Stripe
  static Future<String?> initGateway({
    required String publishableKey,
    String? secretKey,
  }) async {
    _stripeSecretKey = secretKey;
    final res = await _channel.invokeMethod<String>('initGateway', {
      'publishableKey': publishableKey,
    });
    if (kDebugMode) log("initGateway result -> $res");
    return res;
  }

  /// Start Stripe Payment
  static Future<void> startPayment({
    required int amount,
    required String currency,
    required String publishableKey,
  }) async {
    if (_stripeSecretKey == null) {
      log("Stripe secret key not set. Call initGateway first.");
      return;
    }

    try {
      // 1. Create Customer
      final customerResp = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      final customerId = jsonDecode(customerResp.body)['id'];
      if (kDebugMode) log("Customer ID -> $customerId");

      // 2. Create Ephemeral Key
      final ephResp = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Stripe-Version': '2025-08-27.basil',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'customer': customerId},
      );
      final ephemeralKey = jsonDecode(ephResp.body)['secret'];
      if (kDebugMode) log("Ephemeral Key -> $ephemeralKey");

      // 3. Create PaymentIntent
      final piResp = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'customer': customerId,
          'amount': amount.toString(),
          'currency': currency,
          'automatic_payment_methods[enabled]': 'true',
        },
      );
      final clientSecret = jsonDecode(piResp.body)['client_secret'];
      if (kDebugMode) log("PaymentIntent Client Secret -> $clientSecret");

      Future.delayed(const Duration(seconds: 2), () async {
        // 4. Present PaymentSheet UI
        final paySheet = await _channel.invokeMethod('startPayment', {
          'publishableKey': publishableKey,
          'clientSecret': clientSecret,
          'customerId': customerId,
          'ephemeralKey': ephemeralKey,
        });
        if (kDebugMode) log("Pay sheet -> $paySheet");
      });
    } catch (e) {
      log("Error starting payment: $e");
    }
  }

  /// Public method to listen to payment callbacks
  static void setPaymentResultListener(PaymentResultCallback listener) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'paymentSuccess':
          listener("Payment Successful!");
          break;
        case 'paymentCanceled':
          listener("Payment Canceled!");
          break;
        case 'paymentFailed':
          listener("Payment Failed: ${call.arguments ?? 'Unknown Error'}");
          break;
        default:
          break;
      }
    });
  }

  static Future<String?> createPaymentMethod({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String name,
    required String email,
    required String phone,
    required String line1,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) {
    return _channel.invokeMethod('createPaymentMethod', {
      'cardNumber': cardNumber,
      'expMonth': expMonth,
      'expYear': expYear,
      'cvc': cvc,
      'name': name,
      'email': email,
      'phone': phone,
      'line1': line1,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    });
  }
}
