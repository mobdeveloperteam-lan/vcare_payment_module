import UIKit
import Stripe
import StripePaymentSheet

class StripeSetupViewController: UIViewController {

    var publishableKey: String?
    var clientSecret: String?
    var customerId: String?
    var ephemeralKey: String?
    var secretKey: String?
    var clientName: String?
    var merchantId: String? // ✅ Add a variable for your Merchant ID

    var onSuccess: ((_ paymentMethodId: String?, _ paymentMethodDetails: String?) -> Void)?
    var onCancel: (() -> Void)?
    var onFailure: ((_ errorMsg: String) -> Void)?
    
    private var paymentSheet: PaymentSheet?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        guard
            let publishableKey = publishableKey,
            let clientSecret = clientSecret,
            let customerId = customerId,
            let ephemeralKey = ephemeralKey,
            let clientName = clientName,
            let merchantId = merchantId // ✅ Ensure merchantId is passed in
        else {
            dismiss(animated: true) { self.onFailure?("Missing required parameters") }
            return
        }
        
        STPAPIClient.shared.publishableKey = publishableKey
        
        let customerConfig = PaymentSheet.CustomerConfiguration(
            id: customerId,
            ephemeralKeySecret: ephemeralKey
        )
        
        // Prepare default billing details
        var defaultBilling = PaymentSheet.BillingDetails()
        defaultBilling.address = .init(country: "US")
        
        var config = PaymentSheet.Configuration()
        config.merchantDisplayName = clientName
        config.customer = customerConfig
        config.allowsDelayedPaymentMethods = true
        config.defaultBillingDetails = defaultBilling
        
        // Correct way to configure billing details: access properties directly
        config.billingDetailsCollectionConfiguration.name = .always
        config.billingDetailsCollectionConfiguration.phone = .never
        config.billingDetailsCollectionConfiguration.email = .never
        config.billingDetailsCollectionConfiguration.address = .never
        
        // ✅ Add Apple Pay configuration
        config.applePay = .init(
            merchantId: merchantId,
            merchantCountryCode: "US"
        )
        
        self.paymentSheet = PaymentSheet(
            setupIntentClientSecret: clientSecret,
            configuration: config
        )
        
        DispatchQueue.main.async {
            self.paymentSheet?.present(from: self) { result in
                switch result {
                case .completed:
                    self.fetchPaymentMethodId()
                case .canceled:
                    self.dismiss(animated: true) { self.onCancel?() }
                case .failed(let error):
                    self.dismiss(animated: true) { self.onFailure?("Payment failed: \(error.localizedDescription)") }
                }
            }
        }
    }
    
    private func fetchPaymentMethodId() {
        guard let clientSecret = clientSecret,
              let secretKey = secretKey else {
            dismiss(animated: true) { self.onFailure?("Missing secretKey or clientSecret") }
            return
        }
        
        let setupIntentId = clientSecret.components(separatedBy: "_secret").first ?? ""
        let url = URL(string: "https://api.stripe.com/v1/setup_intents/\(setupIntentId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { self.onFailure?("SetupIntent fetch failed: \(error.localizedDescription)") }
                }
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let pmId = json["payment_method"] as? String,
                  !pmId.isEmpty else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { self.onFailure?("PaymentMethod not found in SetupIntent") }
                }
                return
            }
            self.fetchPaymentMethodDetails(pmId)
        }.resume()
    }
    
    private func fetchPaymentMethodDetails(_ pmId: String) {
        guard let secretKey = secretKey else {
            dismiss(animated: true) { self.onFailure?("Missing secretKey") }
            return
        }
        
        let url = URL(string: "https://api.stripe.com/v1/payment_methods/\(pmId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) { self.onFailure?("PaymentMethod fetch failed: \(error.localizedDescription)") }
                }
                return
            }
            
            let pmDetails = data.flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.onSuccess?(pmId, pmDetails)
                }
            }
        }.resume()
    }
}
