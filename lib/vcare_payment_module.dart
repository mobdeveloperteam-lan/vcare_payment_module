import 'vcare_payment_module_platform_interface.dart';
import 'vcare_payment_module_method_channel.dart';

class VcarePaymentModule {
  static final VcarePaymentModulePlatform _platform = MethodChannelVcarePaymentModule();

  static Future<String?> getPlatformVersion() {
    return _platform.getPlatformVersion();
  }

  static Future<String?> startPayment({
    required int amount,
    required String currency,
    required String gateway,
  }) {
    return _platform.startPayment(
      amount: amount,
      currency: currency,
      gateway: gateway,
    );
  }
}
