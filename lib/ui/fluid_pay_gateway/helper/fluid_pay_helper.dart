import '../widgets/fluid_pay_webview.dart';
import 'package:flutter/material.dart';

class FluidPayHelper {
  static GlobalKey<FluidPayWebViewState>? webViewKey;

  static void registerWebViewKey(GlobalKey<FluidPayWebViewState> key) {
    webViewKey = key;
  }

  static void submitPayment() {
    if (webViewKey?.currentState != null) {
      webViewKey!.currentState!.submit();
    } else {
      debugPrint("FluidPay WebView not ready");
    }
  }
}
