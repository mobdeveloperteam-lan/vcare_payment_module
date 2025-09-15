package com.example.vcare_payment_module

import android.content.Context
import androidx.activity.ComponentActivity
import io.flutter.plugin.common.MethodChannel
import com.stripe.android.Stripe
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult
import com.stripe.android.paymentsheet.PaymentSheet.Configuration

class StripeSdk(private val context: Context, private val activity: ComponentActivity) {

    private lateinit var stripe: Stripe

    fun init(publishableKey: String) {
        stripe = Stripe(context, publishableKey)
    }

    fun startPayment(clientSecret: String, amount: Int, currency: String, result: MethodChannel.Result) {
        val paymentSheet = PaymentSheet(activity) { paymentResult: PaymentSheetResult ->
            when (paymentResult) {
                is PaymentSheetResult.Completed -> result.success("Payment Success")
                is PaymentSheetResult.Canceled -> result.success("Payment Cancelled")
                is PaymentSheetResult.Failed -> result.error("PAYMENT_FAILED", paymentResult.error.localizedMessage, null)
            }
        }

        val config = Configuration(merchantDisplayName = "Your App")
        paymentSheet.presentWithPaymentIntent(clientSecret, config)
    }
}
