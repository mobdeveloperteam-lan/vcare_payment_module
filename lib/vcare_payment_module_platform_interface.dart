abstract class VcarePaymentModulePlatform {
  Future<String?> getPlatformVersion();

  Future<String?> startPayment({
    required int amount,
    required String currency,
    required String gateway,
  });
}
