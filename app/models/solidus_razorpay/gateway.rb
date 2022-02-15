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

    def capture(float_amount, order_number, gateway_options); end

    def void(order_number, gateway_options); end

    def purchase(float_amount, payment_source, gateway_options); end

    def create_order(amount, receipt, currency)
      Razorpay::Order.create(amount: amount, currency: currency, receipt: receipt)
    end

    def retrieve_payment(payment_id)
      Razorpay::Payment.fetch(payment_id)
    end

    private

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
