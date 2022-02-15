# frozen_string_literal: true

require 'razorpay'

FactoryBot.define do
  factory :razorpay_payment_method, class: SolidusRazorpay::RazorpayPayment do
    name { 'Razorpay' }
    type { 'SolidusRazorpay::RazorpayPayment' }
    active { true }
    preferences {
      { razorpay_key: 'Razorpay_Key', razorpay_secret: 'Razorpay_Secret', razorpay_test_environment: false }
    }
  end

  factory :razorpay_payment_source, class: SolidusRazorpay::PaymentSource do
    association :payment_method
    razorpay_order_id { "order_#{random_string}" }
    razorpay_payment_id { "payment_#{random_string}" }
    currency { 'INR' }
    status { 'authorized' }
    amount_refunded { 0 }
    refund_status { 'null' }
    captured { false }
    amount { 100 }
    international { false }
    error_code { nil }
    error_description { nil }
    error_source { nil }
    error_step { nil }
    error_reason { nil }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end

def random_string
  ('a'..'z').to_a.shuffle.join
end
