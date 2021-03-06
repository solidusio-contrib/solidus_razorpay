# frozen_string_literal: true

module SolidusRazorpay
  class RazorpayPayment < SolidusSupport.payment_method_parent_class
    preference :razorpay_key, :string
    preference :razorpay_secret, :string

    def gateway_class
      ::SolidusRazorpay::Gateway
    end

    def payment_source_class
      ::SolidusRazorpay::PaymentSource
    end

    def partial_name
      "razorpay"
    end
  end
end
