import Flutter
import UIKit
import Stripe

public class StripeSdkFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "stripe_sdk_flutter", binaryMessenger: registrar.messenger())
    let instance = StripeSdkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      if let args = call.arguments as? [String: Any],
         let publishableKey = args["publishableKey"] as? String {
          STPAPIClient.shared.publishableKey = publishableKey
          result(nil)
      } else {
          result(FlutterError(code: "INIT_ERROR", message: "Missing publishableKey", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
