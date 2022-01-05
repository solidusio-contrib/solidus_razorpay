require 'razorpay'

class SolidusRazorpay::Gateway
  CURRENCY = Spree::Config.currency
  RAZORPAY_KEY = SolidusRazorpay.config.razorpay_key
  COLOR = SolidusRazorpay.config.razorpay_color

  def initialize(options = nil);end

  def authorize(amount, payment_source, gateway_options)
    payment = gateway_options[:originator]
    razorpay_payment_id = payment.payment_source.razorpay_payment_id
    razorpay_payment = retrieve_payment(razorpay_payment_id)
    ActiveMerchant::Billing::Response.new(true, 'Transaction approved', razorpay_payment.attributes,
        authorization: razorpay_payment.id)
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message, {})
  end

  def void(gateway_options, options)
    payment = options[:originator]
    # razorpay_payment_id = SolidusRazorpay::PaymentSource.find(source_id)
    razorpay_payment_id = payment.payment_source.razorpay_payment_id
    razorpay_payment = retrieve_payment(razorpay_payment_id)
    refund_payment(razorpay_payment) if(razorpay_payment.status == 'captured')
    ActiveMerchant::Billing::Response.new(true, 'Transaction void', razorpay_payment.attributes,
        authorization: razorpay_payment.id)
    rescue StandardError => e
      ActiveMerchant::Billing::Response.new(false, e.message, {})
  end

  def create_order(amount, receipt_id)
    order = Razorpay::Order.create(amount: amount, currency: CURRENCY, receipt: receipt_id)
    order
  end

  def retrieve_order(order_id)
    order = Razorpay::Order.fetch(order_id)
    order
  end

  def capture_payment(payment, amount)
    raise 'Razorpay Payment Unauthorized' if payment['status'] != 'authorized'

    options = { amount: amount, currency: CURRENCY }
    payment.capture(options)
  end

  def retrieve_payment(payment_id)
    payment = Razorpay::Payment.fetch(payment_id)
    payment
  end

  def retrieve_payments_for_order(order)
    order.payments
  end

  def refund_payment(payment)
    payment.refund
  end
end
