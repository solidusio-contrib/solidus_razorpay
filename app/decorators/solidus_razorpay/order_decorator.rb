module OrderDecorator

  def self.prepended(base)
    base.after_commit :capture_razorpay_payment
  end

  def capture_razorpay_payment
    return unless self.complete?

    latest_payment = payments.valid.last
    return if latest_payment.blank? || latest_payment.completed?

    gateway = SolidusRazorpay::Gateway.new
    razorpay_payment_id = latest_payment.payment_source.razorpay_payment_id
    razorpay_payment = gateway.retrieve_payment(razorpay_payment_id)
    latest_payment.complete! if razorpay_payment.status == 'captured'
    if razorpay_payment.status == 'authorized'
      gateway.capture_payment(razorpay_payment, latest_payment.amount)
      latest_payment.complete!
    end
  end

  Spree::Order.prepend self
end

