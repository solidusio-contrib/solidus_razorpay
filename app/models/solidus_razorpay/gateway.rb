require 'razorpay'

class SolidusRazorpay::Gateway
  CURRENCY = Spree::Config.currency
  RAZORPAY_KEY = SolidusRazorpay.configuration.razorpay_key
  COLOR = SolidusRazorpay.configuration.razorpay_color

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
