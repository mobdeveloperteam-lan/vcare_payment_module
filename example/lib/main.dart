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
                  "sk_test_51S7YBkBwFOEeLOxUANMzOHjPL340krkd14AObmTKlDYyH3vbued2mL3xgPssA6LEE3bnIaEjXPTHHB99oS9Wuhpi00RRzzlgFc",
              "publish_key":
                  "pk_test_51S7YBkBwFOEeLOxUJATffi9xSWFFq0bwOSwYJro5wo7xPqEXX0AQ2Aaehk60SXiAwyy3VFLxgKKY87zjzBW188K300hqp5uYRL",
            },
          },
          "client_name": "Flex Mobile",
          "zip_code": "Flex Mobile",

        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

