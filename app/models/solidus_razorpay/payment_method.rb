class SolidusRazorpay::PaymentMethod < SolidusSupport.payment_method_parent_class
  preference :razorpay_key, :string
  preference :razorpay_secret, :string
  preference :razorpay_color, :string

  def gateway_class
    ::SolidusRazorpay::Gateway
  end

  def payment_source_class
    ::SolidusRazorpay::PaymentSource
  end

  def partial_name
    "razorpay"
  end
end
