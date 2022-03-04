# frozen_string_literal: true

require 'razorpay'

module SolidusRazorpay
  class Gateway
    def initialize(options)
      Razorpay.setup(options[:razorpay_key], options[:razorpay_secret])
    end

    def authorize(_amount, _payment_source, gateway_options)
      payment = gateway_options[:originator]
      razorpay_payment_id = payment.source.razorpay_payment_id
      razorpay_payment = retrieve_payment(razorpay_payment_id)
      update_razorpay_source(payment.source, razorpay_payment)
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction approved',
        razorpay_payment.attributes,
        authorization: razorpay_payment.id
      )
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message, {})
    end

    def capture(_float_amount, _order_number, gateway_options)
      payment = gateway_options[:originator]
      payment_source = payment.source
      razorpay_payment = retrieve_payment(payment_source.razorpay_payment_id)
      raise 'Razorpay Payment not Authorised' unless verified?(razorpay_payment)

      if razorpay_payment.status == 'authorized'
        razorpay_payment = razorpay_payment.capture({
          amount: payment_source.amount,
          currency: payment_source.currency
        })
      end

      update_razorpay_source(payment_source, razorpay_payment)
      ActiveMerchant::Billing::Response.new(
        true,
        'Transaction captured',
        razorpay_payment.attributes,
        authorization: razorpay_payment.id
      )
    end

    def void(_order_number, gateway_options)
      payment = gateway_options[:originator]
      refund_payment(payment.source, 'Transaction void and refunded')
    end

    def credit(_amount, razorpay_payment_id, _gateway_options)
      payment_source = SolidusRazorpay::PaymentSource.find_by(razorpay_payment_id: razorpay_payment_id)
      refund_payment(payment_source, 'Transaction refunded')
    end

    def purchase(float_amount, _payment_source, gateway_options)
      payment = gateway_options[:originator]
      capture(float_amount, payment.order.number, gateway_options)
    end

    def create_order(amount, receipt, currency)
      Razorpay::Order.create(amount: amount, currency: currency, receipt: receipt)
    end

    def retrieve_order(order_id)
      Razorpay::Order.fetch(order_id)
    end

    def retrieve_payment(payment_id)
      Razorpay::Payment.fetch(payment_id)
    end

    private

    def refund_payment(payment_source, message)
      raise 'Razorpay Payment not Captured' unless payment_source.status == 'captured'

      retrieve_payment(payment_source.razorpay_payment_id).refund
      razorpay_payment = retrieve_payment(payment_source.razorpay_payment_id)
      update_razorpay_source(payment_source, razorpay_payment)
      ActiveMerchant::Billing::Response.new(
        true,
        message,
        razorpay_payment.attributes,
        authorization: razorpay_payment.id
      )
    end

    def verified?(razorpay_payment)
      razorpay_payment.status == 'authorized' || razorpay_payment.status == 'captured'
    end

    def update_razorpay_source(payment_source, razorpay_payment)
      payment_source.currency = razorpay_payment.currency
      payment_source.method = razorpay_payment.method
      payment_source.status = razorpay_payment.status
      payment_source.amount_refunded = razorpay_payment.amount_refunded
      payment_source.refund_status = razorpay_payment.refund_status
      payment_source.captured = razorpay_payment.captured
      payment_source.amount = razorpay_payment.amount
      payment_source.international = razorpay_payment.international
      payment_source.error_code = razorpay_payment.error_code
      payment_source.error_description = razorpay_payment.error_description
      payment_source.error_source = razorpay_payment.error_source
      payment_source.error_step = razorpay_payment.error_step
      payment_source.error_reason = razorpay_payment.error_reason

      payment_source.save!
    end
  end
end
