// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vcare_payment_module/vcare_payment_module_method_channel.dart';

class StripePaymentModule extends StatefulWidget {
  final Map<String, dynamic> details;
  final String clientName;
  final String applePayMerchantID; // Your Merchant ID

  const StripePaymentModule({
    super.key,
    required this.details,
    required this.clientName,
    required this.applePayMerchantID,
  });

  @override
  State<StripePaymentModule> createState() => _StripePaymentModuleState();
}

class _StripePaymentModuleState extends State<StripePaymentModule> {
  String status = "No payment started";
  Map<String, dynamic>? paymentMethod;
  String publishKey = "";
  String secretKey = "";

  void getDetails() {
    Map<String, dynamic> creds = widget.details;
    if (kDebugMode) {
      print(creds);
    }
    if (creds.isNotEmpty) {
      Map<String, dynamic> stripeConfigs = creds;
      if (stripeConfigs.isNotEmpty) {
        publishKey = stripeConfigs["publish_key"] ?? "";
        secretKey = stripeConfigs["secret_key"] ?? "";
      }
      if (publishKey.isEmpty || secretKey.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid credentials")));
      } else {
        startPayment();
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to start payment")));
    }
  }

  @override
  void initState() {
    super.initState();

    VcarePaymentModule.setStripePaymentResultListener((
      result, {
      Map<String, dynamic>? paymentMethod,
    }) {
      // Parse the raw JSON string if present
      if (paymentMethod != null &&
          paymentMethod['paymentMethodDetails'] != null) {
        final rawDetails = paymentMethod['paymentMethodDetails'];
        final parsedDetails = rawDetails is String
            ? jsonDecode(rawDetails)
            : rawDetails;
        paymentMethod['details'] = parsedDetails;
      }

      setState(() {
        status = result;
        this.paymentMethod = paymentMethod;
      });
    });
  }

  Future<void> startPayment() async {
    await VcarePaymentModule.initStripeGateway(
      publishableKey: publishKey,
      secretKey: secretKey,
    );

    await VcarePaymentModule.startStripeSetup(
      publishableKey: publishKey,
      clientName: widget.clientName,
      applePayMerchantID: Platform.isIOS ? widget.applePayMerchantID : "",
    );
  }

  Widget _buildCardPreview() {
    if (paymentMethod == null) return const SizedBox.shrink();
    final details = paymentMethod!['details'];
    if (details == null) return const SizedBox.shrink();

    final card = details['card'] ?? {};
    final billing = details['billing_details'] ?? {};
    final pmId = paymentMethod!['paymentMethodId'] ?? "Unknown";
    final customerID = details['customer'] ?? "Unknown";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.blue),
        title: Text(
          "${card['brand']?.toString().toUpperCase() ?? ''} •••• ${card['last4'] ?? ''}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Cardholder Name: ${billing['name'] ?? 'No Name'}"),
            Row(
              children: [
                Text("Expiration: ${card['exp_month'] ?? ''}"),
                const Text("/"),
                Text("${card['exp_year'] ?? ''}"),
              ],
            ),
            const SizedBox(height: 4),
            Text("Payment Method ID: $pmId"),
            const SizedBox(height: 4),
            Text("Customer ID: $customerID"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: getDetails,
                  child: const Text("Start Setup Payment"),
                ),
                const SizedBox(height: 24),
                Text("Status: $status", style: const TextStyle(fontSize: 16)),
                _buildCardPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
