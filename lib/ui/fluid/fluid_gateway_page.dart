import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vcare_payment_module/ui/fluid/providers/fluid_bottom_sheet_provider.dart';

class FluidGatewayPage extends StatefulWidget {
  const FluidGatewayPage({super.key});

  @override
  State<FluidGatewayPage> createState() => _FluidGatewayPageState();
}

class _FluidGatewayPageState extends State<FluidGatewayPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FluidBottomSheetProvider>(
        context,
        listen: false,
      ).showSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
