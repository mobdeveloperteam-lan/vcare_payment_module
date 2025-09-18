import Flutter
import UIKit

public class VcarePaymentModulePlugin: NSObject, FlutterPlugin {
    
    var methodChannel: FlutterMethodChannel?
    var rootViewController: UIViewController? {
        return UIApplication.shared.delegate?.window??.rootViewController
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "vcare_payment_module", binaryMessenger: registrar.messenger())
        let instance = VcarePaymentModulePlugin()
        instance.methodChannel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initStripeGateway":
            result("Gateway Initialized")

        case "startStripeSetupSheet":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            startSetupSheet(with: args)
            result("Setup Sheet Launched")

        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startSetupSheet(with args: [String: Any]) {
        let vc = StripeSetupViewController()
        vc.modalPresentationStyle = .fullScreen
        
        vc.publishableKey = args["publishableKey"] as? String
        vc.clientSecret = args["clientSecret"] as? String
        vc.customerId = args["customerId"] as? String
        vc.ephemeralKey = args["ephemeralKey"] as? String
        vc.secretKey = args["secretKey"] as? String
        vc.clientName = args["clientName"] as? String
        vc.merchantId = args["applePayMerchantID"] as? String
        
        vc.onSuccess = { paymentMethodId, paymentMethodDetails in
            let result: [String: String] = [
                "paymentMethodId": paymentMethodId ?? "",
                "paymentMethodDetails": paymentMethodDetails ?? ""
            ]
            self.methodChannel?.invokeMethod("paymentSuccess", arguments: result)
        }
        
        vc.onCancel = {
            self.methodChannel?.invokeMethod("paymentCanceled", arguments: nil)
        }
        
        vc.onFailure = { errorMsg in
            self.methodChannel?.invokeMethod("paymentFailed", arguments: errorMsg)
        }
        
        rootViewController?.present(vc, animated: true, completion: nil)
    }
}
