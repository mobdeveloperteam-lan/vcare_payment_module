import 'package:flutter/material.dart';
import 'package:vcare_payment_module/vcare_payment_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VcarePaymentView(
        input: {
          "client_supported_payment_sdk_config": {
            "supports_multi_gateway": false,
            "gateways": ["stripe"],
            "stripe_configs": {
              "secret_key":
                  "",
              "publish_key":
                  "",
            },
          },
          "client_name": "Flex Mobile",
          "apple_pay_merchant_id":
              "", // Your Merchant ID
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
