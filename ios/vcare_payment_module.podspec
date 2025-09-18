Pod::Spec.new do |s|
  s.name             = 'vcare_payment_module'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Stripe PaymentSheet'
  s.description      = 'Flutter plugin to integrate Stripe PaymentSheet'
  s.homepage         = 'https://your-homepage.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sandeep' => 'you@example.com' }
  s.source           = { :path => '.' }

  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'
  s.static_framework = false    # ✅ dynamic framework required for Swift modules

  s.source_files     = 'Classes/**/*'

  # Dependencies
  s.dependency 'Flutter'
  s.dependency 'Stripe', '~> 24.0'
  s.dependency 'StripePaymentSheet', '~> 24.0'
end
