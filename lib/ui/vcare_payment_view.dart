import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vcare_payment_module/vcare_payment_module_method_channel.dart';

class VcarePaymentScreen extends StatefulWidget {
  const VcarePaymentScreen({super.key});

  @override
  State<VcarePaymentScreen> createState() => _VcarePaymentScreenState();
}

class _VcarePaymentScreenState extends State<VcarePaymentScreen> {
  final cardNumber = TextEditingController();
  final expMonth = TextEditingController();
  final expYear = TextEditingController();
  final cvc = TextEditingController();

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final line1 = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final postal = TextEditingController();
  final country = TextEditingController();

  String log = "";

  Future<void> startPayment() async {
    setState(() => log = "Creating PaymentMethod...");

    try {
      final paymentMethodId = await VcarePaymentModule.createPaymentMethod(
        cardNumber: cardNumber.text.trim(),
        expMonth: int.parse(expMonth.text),
        expYear: int.parse(expYear.text),
        cvc: cvc.text.trim(),
        name: name.text,
        email: email.text,
        phone: phone.text,
        line1: line1.text,
        city: city.text,
        state: state.text,
        postalCode: postal.text,
        country: country.text,
      );

      if (paymentMethodId == null) {
        setState(() => log = "Failed to create payment method");
        return;
      }

      setState(
        () =>
            log = "PaymentMethod: $paymentMethodId\nCreating PaymentIntent...",
      );

      const secretKey = ""; // for testing only

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': '1000',
          'currency': 'usd',
          'payment_method': paymentMethodId,
          'confirmation_method': 'manual',
          'confirm': 'true',
        },
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() => log = "Payment Success ✅\n$body");
      } else {
        setState(() => log = "Payment Failed ❌\n${body['error'] ?? body}");
      }
    } catch (e) {
      setState(() => log = "Error: $e");
    }
  }

  Widget field(String label, TextEditingController c) => TextField(
    controller: c,
    decoration: InputDecoration(labelText: label),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stripe Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field("Card Number", cardNumber),
            Row(
              children: [
                Expanded(child: field("MM", expMonth)),
                const SizedBox(width: 8),
                Expanded(child: field("YYYY", expYear)),
              ],
            ),
            field("CVC", cvc),
            const Divider(),
            field("Name", name),
            field("Email", email),
            field("Phone", phone),
            field("Address Line 1", line1),
            field("City", city),
            field("State", state),
            field("Postal Code", postal),
            field("Country", country),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: startPayment,
              child: const Text("Pay \$10"),
            ),
            const SizedBox(height: 20),
            Text(log),
          ],
        ),
      ),
    );
  }
}
