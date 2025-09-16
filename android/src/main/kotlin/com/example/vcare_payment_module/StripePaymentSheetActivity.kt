package com.example.vcare_payment_module

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import com.stripe.android.PaymentConfiguration
import com.stripe.android.paymentsheet.PaymentSheet
import com.stripe.android.paymentsheet.PaymentSheetResult
import okhttp3.*
import org.json.JSONObject
import java.io.IOException

class StripeSetupActivity : ComponentActivity() {

    private lateinit var paymentSheet: PaymentSheet
    private lateinit var clientSecret: String
    private lateinit var customerId: String
    private lateinit var ephemeralKey: String
    private lateinit var secretKey: String
    private lateinit var clientName: String
    private val TAG = "StripeSetupActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val publishableKey = intent.getStringExtra("publishableKey") ?: ""
        clientSecret = intent.getStringExtra("clientSecret") ?: ""
        customerId = intent.getStringExtra("customerId") ?: ""
        ephemeralKey = intent.getStringExtra("ephemeralKey") ?: ""
        secretKey = intent.getStringExtra("secretKey") ?: ""
        clientName = intent.getStringExtra("clientName") ?: ""

        PaymentConfiguration.init(applicationContext, publishableKey)
        paymentSheet = PaymentSheet(this, ::onPaymentSheetResult)

        val config = PaymentSheet.Configuration(
            merchantDisplayName = clientName,
            customer = PaymentSheet.CustomerConfiguration(
                id = customerId,
                ephemeralKeySecret = ephemeralKey
            ),
            allowsDelayedPaymentMethods = true,
            defaultBillingDetails = PaymentSheet.BillingDetails(
             //name = "John Doe",
             address = PaymentSheet.Address(
              // city = "New York",
              // state = "NY",
               country = "US"
              )
            ),
            billingDetailsCollectionConfiguration = PaymentSheet.BillingDetailsCollectionConfiguration(
                name = PaymentSheet.BillingDetailsCollectionConfiguration.CollectionMode.Always, // 👈 Show Cardholder Name field
                email = PaymentSheet.BillingDetailsCollectionConfiguration.CollectionMode.Never,
              //  phone = PaymentSheet.BillingDetailsCollectionConfiguration.CollectionMode.Automatic,
                address = PaymentSheet.BillingDetailsCollectionConfiguration.AddressCollectionMode.Never
            )
        )

        paymentSheet.presentWithSetupIntent(clientSecret, config)
    }

    private fun onPaymentSheetResult(result: PaymentSheetResult) {
        when (result) {
            is PaymentSheetResult.Completed -> fetchPaymentMethodId()
            is PaymentSheetResult.Canceled -> {
                setResult(Activity.RESULT_CANCELED)
                finish()
            }
            is PaymentSheetResult.Failed -> {
                setResult(Activity.RESULT_FIRST_USER)
                finish()
            }
        }
    }

    private fun fetchPaymentMethodId() {
        val setupIntentId = clientSecret.split("_secret")[0]
        val client = OkHttpClient()
        val request = Request.Builder()
            .url("https://api.stripe.com/v1/setup_intents/$setupIntentId")
            .header("Authorization", "Bearer $secretKey")
            .get()
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                Log.e(TAG, "Failed to fetch SetupIntent: ${e.localizedMessage}")
                setResult(Activity.RESULT_FIRST_USER)
                finish()
            }

            override fun onResponse(call: Call, response: Response) {
                response.use {
                    val body = it.body?.string()
                    val pmId = JSONObject(body ?: "{}").optString("payment_method", "")
                    if (pmId.isNotEmpty()) fetchPaymentMethodDetails(pmId)
                    else {
                        setResult(Activity.RESULT_FIRST_USER)
                        finish()
                    }
                }
            }
        })
    }

    private fun fetchPaymentMethodDetails(pmId: String) {
        val client = OkHttpClient()
        val request = Request.Builder()
            .url("https://api.stripe.com/v1/payment_methods/$pmId")
            .header("Authorization", "Bearer $secretKey")
            .get()
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                Log.e(TAG, "Failed to fetch PaymentMethod: ${e.localizedMessage}")
                setResult(Activity.RESULT_FIRST_USER)
                finish()
            }

            override fun onResponse(call: Call, response: Response) {
                response.use {
                    val body = it.body?.string()
                    val intent = Intent().apply {
                        putExtra("paymentMethodId", pmId)
                        putExtra("paymentMethodDetails", body)
                    }
                    setResult(Activity.RESULT_OK, intent)
                    finish()
                }
            }
        })
    }
}
