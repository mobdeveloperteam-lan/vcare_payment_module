package com.example.vcare_payment_module

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import com.stripe.android.PaymentConfiguration
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult

class StripePaymentActivity : ComponentActivity() {

    private lateinit var paymentSheet: PaymentSheet
    private lateinit var clientSecret: String
    private lateinit var customerId: String
    private lateinit var ephemeralKey: String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val publishableKey = intent.getStringExtra("publishableKey") ?: ""
        clientSecret = intent.getStringExtra("clientSecret") ?: ""
        customerId = intent.getStringExtra("customerId") ?: ""
        ephemeralKey = intent.getStringExtra("ephemeralKey") ?: ""

        PaymentConfiguration.init(applicationContext, publishableKey)

        // ✅ This works only in ComponentActivity
        paymentSheet = PaymentSheet(this, ::onPaymentSheetResult)

        val config = PaymentSheet.Configuration(
            merchantDisplayName = "Demo Merchant",
            customer = PaymentSheet.CustomerConfiguration(
                id = customerId,
                ephemeralKeySecret = ephemeralKey
            ),
            allowsDelayedPaymentMethods = true
        )

        paymentSheet.presentWithPaymentIntent(clientSecret, config)
    }

    private fun onPaymentSheetResult(result: PaymentSheetResult) {
        when (result) {
            is PaymentSheetResult.Completed -> {
                Log.i("StripePaymentActivity", "Payment completed ${result}")
                setResult(RESULT_OK)
            }
            is PaymentSheetResult.Canceled -> {
                Log.i("StripePaymentActivity", "Payment canceled")
                setResult(RESULT_CANCELED)
            }
            is PaymentSheetResult.Failed -> {
                Log.e("StripePaymentActivity", "Payment failed: ${result.error.localizedMessage}")
                setResult(RESULT_FIRST_USER)
            }
        }
        finish()
    }
}
