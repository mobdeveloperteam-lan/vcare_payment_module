import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

typedef PaymentResultCallback =
    void Function(String result, {Map<String, dynamic>? paymentMethod});

class VcarePaymentModule {
  static const MethodChannel _channel = MethodChannel('vcare_payment_module');
  static String? _stripeSecretKey;

  /// Initialize Stripe (store secretKey for in-app API calls)
  static Future<String?> initStripeGateway({
    required String publishableKey,
    required String secretKey,
  }) async {
    _stripeSecretKey = secretKey;
    final res = await _channel.invokeMethod<String>('initStripeGateway', {
      'publishableKey': publishableKey,
    });
    if (kDebugMode) log("✅ initGateway result -> $res");
    return res;
  }

  /// Start SetupIntent flow entirely from Flutter
  static Future<void> startStripeSetup({
    required String publishableKey,
    required String clientName,
  }) async {
    if (_stripeSecretKey == null) {
      if (kDebugMode) {
        log("❌ Stripe secret key not set");
      }
      return;
    }

    try {
      // 1️⃣ Create Customer
      final customerResp = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      final customerBody = jsonDecode(customerResp.body);
      final customerId = customerBody['id'];
      if (kDebugMode) {
        log("✅ Customer created: $customerId");
      }

      // 2️⃣ Create Ephemeral Key
      final ephResp = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Stripe-Version': '2025-08-27.basil',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'customer': customerId},
      );
      final ephBody = jsonDecode(ephResp.body);
      final ephemeralKey = ephBody['secret'];
      if (kDebugMode) {
        log("✅ Ephemeral key created: $ephemeralKey");
      }

      // 3️⃣ Create SetupIntent
      final setupResp = await http.post(
        Uri.parse('https://api.stripe.com/v1/setup_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'customer': customerId, 'payment_method_types[]': 'card'},
      );
      final setupBody = jsonDecode(setupResp.body);
      final clientSecret = setupBody['client_secret'];
      if (kDebugMode) {
        log("✅ SetupIntent created: $clientSecret");
      }

      // 4️⃣ Launch native Setup Sheet via MethodChannel
      await _channel.invokeMethod('startStripeSetupSheet', {
        'publishableKey': publishableKey,
        'clientSecret': clientSecret,
        'customerId': customerId,
        'ephemeralKey': ephemeralKey,
        'secretKey': _stripeSecretKey,
        'clientName': clientName,
      });
      if (kDebugMode) {
        log("🚀 Setup sheet launched");
      }
    } catch (e, s) {
      if (kDebugMode) {
        log("❌ Error starting setup: $e\n$s");
      }
    }
  }

  /// Listen to setup/payment callbacks
  static void setStripePaymentResultListener(PaymentResultCallback listener) {
    _channel.setMethodCallHandler((call) async {
      if (kDebugMode) {
        log(
          "📩 Flutter received callback: ${call.method}, arguments: ${call.arguments}",
        );
      }
      switch (call.method) {
        case 'paymentSuccess':
          final arg = call.arguments as Map;
          final pmDetails = arg['details'] != null
              ? jsonDecode(arg['details'])
              : null;
          listener(
            "Setup Completed!",
            paymentMethod: {...arg, 'details': pmDetails},
          );
          break;
        case 'paymentCanceled':
          listener("Setup Canceled!", paymentMethod: null);
          break;
        case 'paymentFailed':
          listener("Setup Failed!", paymentMethod: null);
          break;
      }
    });
  }
}
