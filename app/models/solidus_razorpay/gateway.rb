# frozen_string_literal: true

require 'razorpay'

module SolidusRazorpay
  class Gateway
    CURRENCY = Spree::Config.currency
    RAZORPAY_KEY = SolidusRazorpay.config.razorpay_key
    COLOR = SolidusRazorpay.config.razorpay_color

    def initialize(options = nil); end

    def authorize(_amount, _payment_source, gateway_options)
      payment = gateway_options[:originator]
      razorpay_payment_id = payment.payment_source.razorpay_payment_id
      razorpay_payment = retrieve_payment(razorpay_payment_id)
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction approved',
        razorpay_payment.attributes,
        authorization: razorpay_payment.id
      )
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message, {})
    end

    def void(_gateway_options, options)
      payment = options[:originator]
      razorpay_payment_id = payment.payment_source.razorpay_payment_id
      razorpay_payment = retrieve_payment(razorpay_payment_id)
      refund_payment(razorpay_payment) if razorpay_payment.status == 'captured'
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction void',
        razorpay_payment.attributes,
        authorization: razorpay_payment.id
      )
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message, {})
    end

    def create_order(amount, receipt_id)
      Razorpay::Order.create(amount: amount, currency: CURRENCY, receipt: receipt_id)
    end

    def retrieve_order(order_id)
      Razorpay::Order.fetch(order_id)
    end

    def capture_payment(payment, amount)
      raise 'Razorpay Payment Unauthorized' if payment.status != 'authorized'

      options = { amount: amount, currency: CURRENCY }
      payment.capture(options)
    end

    def retrieve_payment(payment_id)
      Razorpay::Payment.fetch(payment_id)
    end

    def retrieve_payments_for_order(order)
      order.payments
    end

    def refund_payment(payment)
      payment.refund
    end
  end
end
