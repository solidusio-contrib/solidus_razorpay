class SolidusRazorpay::PaymentMethod < SolidusSupport.payment_method_parent_class
  preference :key, :string
  preference :environment, :string
  preference :secret, :string

  def gateway_class
    ::Razorpay::Gateway
  end

  def payment_source_class
    ::Razorpay::PaymentSource
  end

  def partial_name
    "razorpay"
  end
end
