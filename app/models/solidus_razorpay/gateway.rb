# frozen_string_literal: true

module SolidusRazorpay
  class Gateway
    def initialize(razorpay_key, razorpay_secret)
      Razorpay.setup(razorpay_key, razorpay_secret)
    end

    def authorize(_amount, payment_source, _gateway_options); end

    def capture(float_amount, order_number, gateway_options); end

    def void(order_number, gateway_options); end

    def purchase(float_amount, payment_source, gateway_options); end
  end
end
