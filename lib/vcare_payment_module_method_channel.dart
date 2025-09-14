import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'vcare_payment_module_platform_interface.dart';

class MethodChannelVcarePaymentModule extends VcarePaymentModulePlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('vcare_payment_module');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> startPayment({
    required int amount,
    required String currency,
    required String gateway,
  }) async {
    final result = await methodChannel.invokeMethod<String>('startPayment', {
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
    });
    return result;
  }
}
