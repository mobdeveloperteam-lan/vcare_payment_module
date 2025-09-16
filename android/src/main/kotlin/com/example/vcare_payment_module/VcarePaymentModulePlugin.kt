package com.example.vcare_payment_module

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class VcarePaymentModulePlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private val SETUP_REQUEST_CODE = 1001

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "vcare_payment_module")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initStripeGateway" -> result.success("Gateway Initialized")
            "startStripeSetupSheet" -> {
                val intent = Intent(activity, StripeSetupActivity::class.java).apply {
                    putExtra("publishableKey", call.argument<String>("publishableKey"))
                    putExtra("clientSecret", call.argument<String>("clientSecret"))
                    putExtra("customerId", call.argument<String>("customerId"))
                    putExtra("ephemeralKey", call.argument<String>("ephemeralKey"))
                    putExtra("secretKey", call.argument<String>("secretKey"))
                    putExtra("clientName", call.argument<String>("clientName"))
                }
                activity?.startActivityForResult(intent, SETUP_REQUEST_CODE)
                result.success("Setup Sheet Launched")
            }
            else -> result.notImplemented()
        }
    }

    private fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == SETUP_REQUEST_CODE) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    val pmId = data?.getStringExtra("paymentMethodId")
                    val pmDetails = data?.getStringExtra("paymentMethodDetails")
                    val args = HashMap<String, String?>()
                    args["paymentMethodId"] = pmId
                    args["paymentMethodDetails"] = pmDetails
                    channel.invokeMethod("paymentSuccess", args)
                }
                Activity.RESULT_CANCELED -> channel.invokeMethod("paymentCanceled", null)
                Activity.RESULT_FIRST_USER -> channel.invokeMethod("paymentFailed", null)
            }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
            handleActivityResult(requestCode, resultCode, data)
            true
        }
    }

    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() { activity = null }
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}
}
