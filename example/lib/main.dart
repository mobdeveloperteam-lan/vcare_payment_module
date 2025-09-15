import 'package:flutter/material.dart';
import 'package:vcare_payment_module/vcare_payment_module.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: VcarePaymentScreen());
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _result;

  @override
  void initState() {
    super.initState();

    // Set up listener for payment results
    VcarePaymentModule.setPaymentResultListener((result) {
      setState(() => _result = result);
    });
  }

  // void _pay() async {
  //   try {
  //     // 1. Initialize Stripe
  //     final init = await VcarePaymentModule.initGateway(
  //       publishableKey:
  //           '',
  //       secretKey:
  //           '', // TEST ONLY
  //     );
  //     setState(() => _result = "Init Gateway: $init");

  //     // 2. Wait a tiny bit to ensure Activity is attached
  //     await Future.delayed(const Duration(milliseconds: 100));

  //     // 3. Start payment
  //     await VcarePaymentModule.startPayment(
  //       amount: 100, // 1 USD in cents
  //       currency: 'usd',
  //       publishableKey:
  //           '',
  //     );

  //     // Result will be handled in the listener
  //   } catch (e) {
  //     setState(() => _result = 'Error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vcare Payment Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // _pay();
                });
              },
              child: const Text("Pay with Stripe"),
            ),
            const SizedBox(height: 20),
            if (_result != null)
              SelectableText(
                _result!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
