# frozen_string_literal: true

module SolidusRazorpay
  module Api
    module CheckoutHelper
      def create_order(params, payment_method)
        receipt = params[:receipt]
        amount = params[:amount]
        order = Spree::Order.find(params[:orderId])

        razorpay_key = payment_method.preferences[:razorpay_key]
        razorpay_secret = payment_method.preferences[:razorpay_secret]

        gateway = SolidusRazorpay::Gateway.new({ razorpay_key: razorpay_key, razorpay_secret: razorpay_secret })
        gateway.create_order(amount, receipt, order.currency)
      end
    end
  end
end
