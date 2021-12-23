class AddRazorpayToPaymentMethod < ActiveRecord::Migration[6.1]
  def up
    SolidusRazorpay::PaymentMethod.new(
      name: 'Razorpay',
      preference_source: "razorpay_credentials"
    ).save
  end

  def down
    record = Spree::PaymentMethod.find_by(name: 'Razorpay')
    record.destroy if record.present?
  end
end
