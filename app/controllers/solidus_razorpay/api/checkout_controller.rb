# frozen_string_literal: true

module SolidusRazorpay
  module Api
    class CheckoutController < ApplicationController
      include SolidusRazorpay::Api::CheckoutHelper
      protect_from_forgery unless: -> { request.format.json? }

      def index
        payment_method = set_payment_method
        razorpay_order = create_order(params, payment_method)
        razorpay_key = payment_method.preferences[:razorpay_key]
        respond_to do |format|
          format.json {
            render json: { success: true, razorpayOrderId: razorpay_order.id, razorpayKey: razorpay_key }
          }
        end
      rescue StandardError => e
        error_message = e.to_s
        logger.error error_message
        respond_to do |format|
          format.json { render json: { success: false } }
        end
      end

      private

      def set_payment_method
        payment_method_id = params[:paymentMethodId]
        Spree::PaymentMethod.find(payment_method_id)
      end
    end
  end
end
