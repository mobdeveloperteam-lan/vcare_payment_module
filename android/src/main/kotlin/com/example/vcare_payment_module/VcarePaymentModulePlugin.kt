package com.example.vcare_payment_module

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** VcarePaymentModulePlugin */
class VcarePaymentModulePlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "vcare_payment_module")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }

      "startPayment" -> {
        val amount = call.argument<Int>("amount") ?: 0
        val currency = call.argument<String>("currency") ?: "INR"
        val gateway = call.argument<String>("gateway") ?: ""

        when (gateway.lowercase()) {
          "stripe" -> {
            Log.d("VcarePaymentModule", "Starting payment via Stripe")
            // TODO: Integrate Stripe Android SDK here
            result.success("Stripe payment started for $amount $currency")
          }

          "razorpay" -> {
            Log.d("VcarePaymentModule", "Starting payment via Razorpay")
            // TODO: Integrate Razorpay Android SDK here
            result.success("Razorpay payment started for $amount $currency")
          }

          else -> {
            result.error("INVALID_GATEWAY", "Unsupported payment gateway: $gateway", null)
          }
        }
      }

      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
