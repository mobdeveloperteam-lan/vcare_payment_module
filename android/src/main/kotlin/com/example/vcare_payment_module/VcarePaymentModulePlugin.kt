package com.example.vcare_payment_module

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VcarePaymentModulePlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private val TAG = "VcarePaymentModule"

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "vcare_payment_module")
        channel.setMethodCallHandler(this)
        Log.i(TAG, "Plugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "initGateway" -> {
                result.success("Stripe initialized")
            }

            "startPayment" -> {
                val act = activity
                if (act == null) {
                    result.error("NO_ACTIVITY", "Activity not attached yet", null)
                    return
                }

                val intent = Intent(act, StripePaymentActivity::class.java).apply {
                    putExtra("publishableKey", call.argument<String>("publishableKey") ?: "")
                    putExtra("clientSecret", call.argument<String>("clientSecret") ?: "")
                    putExtra("customerId", call.argument<String>("customerId") ?: "")
                    putExtra("ephemeralKey", call.argument<String>("ephemeralKey") ?: "")
                }

                act.startActivity(intent)
                result.success("Payment sheet launched")
            }

            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        Log.i(TAG, "Activity attached: $activity")
    }

    override fun onDetachedFromActivity() { activity = null }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
