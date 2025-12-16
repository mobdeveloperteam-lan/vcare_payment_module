import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vcare_payment_module/ui/fluid_pay_gateway/providers/fluid_gateway_bottom_sheet_provider.dart';

class FluidPayGatewayPage extends StatefulWidget {
  const FluidPayGatewayPage({super.key});

  @override
  State<FluidPayGatewayPage> createState() => _FluidPayGatewayPageState();
}

class _FluidPayGatewayPageState extends State<FluidPayGatewayPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FluidGateWayBottomSheetProvider>(
        context,
        listen: false,
      ).showSheet(
        context,
        apiKey: "pub_31uSkmo5HcVIZrvXUVUvVzUBrjS",
        tokenizerUrl: "https://sandbox.fluidpay.com/tokenizer/tokenizer.js",
        onClose: (message) {
          if (message == "load_failed") {
            debugPrint("❌ WebView failed to load");
          } else if (message == "closed_by_user") {
            debugPrint("ℹ️ User closed manually");
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
