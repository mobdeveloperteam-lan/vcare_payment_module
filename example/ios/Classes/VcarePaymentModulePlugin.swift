import Flutter
import UIKit

public class VcarePaymentModulePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "vcare_payment_module", binaryMessenger: registrar.messenger())
    let instance = VcarePaymentModulePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)

    case "startPayment":
      guard let args = call.arguments as? [String: Any],
            let amount = args["amount"] as? Int,
            let currency = args["currency"] as? String,
            let gateway = args["gateway"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing payment arguments", details: nil))
        return
      }

      switch gateway.lowercased() {
      case "stripe":
        result("Stripe payment started for \(amount) \(currency)")
      case "razorpay":
        result("Razorpay payment started for \(amount) \(currency)")
      default:
        result(FlutterError(code: "INVALID_GATEWAY", message: "Unsupported gateway: \(gateway)", details: nil))
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
