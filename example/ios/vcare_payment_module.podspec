Pod::Spec.new do |s|
  s.name             = 'vcare_payment_module'
  s.version          = '0.0.1'
  s.summary          = 'Stripe PaymentSheet plugin for Flutter'
  s.description      = 'A Flutter plugin to integrate Stripe PaymentSheet.'
  s.homepage         = 'https://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Sandeep' => 'you@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  # ✅ Stripe dependency
  s.dependency 'Stripe', '~> 24.23.2'

  # iOS deployment target
  s.platform         = :ios, '14.0'

  s.swift_version = '5.0'
end
