import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vcare_payment_module/ui/fluid/providers/fluid_bottom_sheet_provider.dart';
import 'package:vcare_payment_module/ui/fluid/providers/fluid_card_form_provider.dart';
import 'package:vcare_payment_module/vcare_payment_module.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FluidBottomSheetProvider()),
        ChangeNotifierProvider(create: (_) => FluidCardFormProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
            "gateways": ["fluid"],
            "stripe_configs": {"secret_key": "", "publish_key": ""},
          },
          "client_name": "Flex Mobile",
          "apple_pay_merchant_id":
              "merchant.com.flexmobile.appp", // Your Merchant ID
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
