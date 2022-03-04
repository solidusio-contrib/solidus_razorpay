# frozen_string_literal: true

module SolidusRazorpay
  module Api
    module CheckoutHelper
      def create_order(params, payment_method)
        razorpay_key = payment_method.preferences[:razorpay_key]
        razorpay_secret = payment_method.preferences[:razorpay_secret]
        gateway = SolidusRazorpay::Gateway.new({ razorpay_key: razorpay_key, razorpay_secret: razorpay_secret })

        receipt = params[:receipt]
        amount = params[:amount]

        order = Spree::Order.find(params[:orderId])
        razorpay_order_id = order.razorpay_order_id

        razorpay_order = if razorpay_order_id.present?
                           gateway.retrieve_order(razorpay_order_id)
                         else
                           gateway.create_order(amount, receipt, order.currency)
                         end

        order.update(razorpay_order_id: razorpay_order.id)
        razorpay_order
      end
    end
  end
end
