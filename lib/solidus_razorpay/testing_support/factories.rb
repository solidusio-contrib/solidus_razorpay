# frozen_string_literal: true

FactoryBot.define do
  factory :razorpay_payment_method, class: SolidusRazorpay::PaymentMethod do
    name { 'Razorpay' }
  end

  factory :razorpay_payment_source, class: SolidusRazorpay::PaymentSource do
    order
    payment_method { create(:razorpay_payment_method) }
    razorpay_order_id { "order_#{SecureRandom.hex}" }
  end
end
