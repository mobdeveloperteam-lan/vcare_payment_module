import 'package:flutter/material.dart';
import 'package:vcare_payment_module/ui/fluid_pay_gateway/pages/fluid_pay_gateway_page.dart';
import 'package:vcare_payment_module/ui/multi_gateway_page.dart';
import 'package:vcare_payment_module/ui/stripe_payment_module.dart';

class VcarePaymentView extends StatefulWidget {
  final Map<String, dynamic> input;
  const VcarePaymentView({super.key, this.input = const {}});

  @override
  State<VcarePaymentView> createState() => _VcarePaymentViewState();
}

class _VcarePaymentViewState extends State<VcarePaymentView> {
  String paymentModuleState = "loading";
  String paymentGateway = "";
  bool supportsMultiGateWay = false;
  List<String> gateWays = [];
  Map<String, dynamic> stripeDetails = {};
  String clientName = "";
  String applePayMerchantID = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Display dialog after UI has rerendered
      analyzeInput();
    });
  }

  void analyzeInput() {
    if (widget.input.isNotEmpty) {
      if (widget.input.containsKey("client_supported_payment_sdk_config")) {
        setPaymentModuleState(
          widget.input["client_supported_payment_sdk_config"],
        );
        clientName = widget.input['client_name'] ?? "";
        applePayMerchantID =
            widget.input['apple_pay_merchant_id'] ?? ""; // Your Merchant ID
      } else {
        paymentModuleTruncate();
      }
    } else {
      paymentModuleTruncate();
    }
    setState(() {});
  }

  void paymentModuleTruncate() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        paymentModuleState = "Could not found payment details";
      });
    });
  }

  void setPaymentModuleState(
    Map<String, dynamic> clientSupportedPaymentSdkConfig,
  ) {
    if (clientSupportedPaymentSdkConfig.isNotEmpty) {
      supportsMultiGateWay =
          clientSupportedPaymentSdkConfig["supports_multi_gateway"] ?? false;
      gateWays = clientSupportedPaymentSdkConfig["gateways"] ?? [];
      stripeDetails = clientSupportedPaymentSdkConfig["stripe_configs"] ?? {};

      if (gateWays.isNotEmpty) {
        paymentModuleState = "gateway found";
      }
      if (!supportsMultiGateWay) {
        paymentGateway = gateWays.first;
      }
      if (paymentGateway.isEmpty && gateWays.isEmpty) {
        paymentModuleTruncate();
      }
    }
  }

  Widget loadUI() {
    if (paymentModuleState == "loading") {
      return Center(child: CircularProgressIndicator());
    } else {
      if (paymentModuleState == "gateway found") {
        if (supportsMultiGateWay) {
          return MultiGatewayPage(gateWays: gateWays);
        } else {
          if (paymentGateway == "stripe") {
            return StripePaymentModule(
              details: stripeDetails,
              clientName: clientName,
              applePayMerchantID: applePayMerchantID,
            );
          } else if (paymentGateway == "fluid") {
            return FluidPayGatewayPage();
          }
        }
      } else {
        return Center(child: Text(paymentModuleState));
      }
    }
    return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: loadUI(),
      ),
    );
  }
}
