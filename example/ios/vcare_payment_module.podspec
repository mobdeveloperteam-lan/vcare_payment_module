Pod::Spec.new do |s|
  s.name             = 'vcare_payment_module'
  s.version          = '0.0.1'
  s.summary          = 'A unified Flutter plugin for multiple payment gateways.'
  s.description      = <<-DESC
A Flutter plugin that allows payments via multiple gateways (e.g., Stripe, Razorpay) using a unified API.
                       DESC
  s.homepage         = 'https://github.com/your_username/vcare_payment_module'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your@email.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.ios.deployment_target = '11.0'
  s.swift_version    = '5.0'
end
