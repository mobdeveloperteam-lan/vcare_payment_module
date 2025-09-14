// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:vcare_payment_module/vcare_payment_module.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _result;

  Future<void> _payWithGateway(String gateway) async {
    final result = await VcarePaymentModule.startPayment(
      amount: 1000,
      currency: 'INR',
      gateway: gateway,
    );
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vcare Payment Module Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _payWithGateway('stripe'),
              child: Text('Pay with Stripe'),
            ),
            ElevatedButton(
              onPressed: () => _payWithGateway('razorpay'),
              child: Text('Pay with Razorpay'),
            ),
            if (_result != null) Text("Result: $_result"),
          ],
        ),
      ),
    );
  }
}
