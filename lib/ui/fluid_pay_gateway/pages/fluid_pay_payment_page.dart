import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vcare_payment_module/ui/fluid_pay_gateway/helper/fluid_pay_helper.dart';
import '../providers/fluid_pay_provider.dart';
import '../widgets/fluid_pay_webview.dart';

class FluidPayPaymentGateWayPage extends StatefulWidget {
  const FluidPayPaymentGateWayPage({super.key});

  @override
  State<FluidPayPaymentGateWayPage> createState() =>
      _FluidPayPaymentGateWayPageState();
}

class _FluidPayPaymentGateWayPageState
    extends State<FluidPayPaymentGateWayPage> {
  final GlobalKey<FluidPayWebViewState> _webViewKey =
      GlobalKey<FluidPayWebViewState>();

  @override
  void initState() {
    super.initState();

    // Register global key for helper
    FluidPayHelper.registerWebViewKey(_webViewKey);

    // Reset provider state every time page appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FluidPayProvider>(context, listen: false).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FluidPayProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: provider.containerHeight,
            child: FluidPayWebView(
              key: _webViewKey,
              apiKey: "pub_31uSkmo5HcVIZrvXUVUvVzUBrjS",
              tokenizerUrl:
                  "https://sandbox.fluidpay.com/tokenizer/tokenizer.js",
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              FluidPayHelper.submitPayment(); // global submit call
            },
            child: const Text("Submit Payment"),
          ),
          const SizedBox(height: 20),
          Text(
            "Token: ${provider.token}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
