class CreateSolidusRazorpayPaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_razorpay_payment_sources do |t|
      t.integer :payment_method_id, index: true
      t.string :razorpay_order_id, null: false
      t.string :razorpay_payment_id
      t.string :currency
      t.string :method
      t.string :status
      t.integer :amount_refunded
      t.integer :refund_status, default: 0
      t.boolean :captured
      t.integer :amount
      t.boolean :international
      t.string :error_code
      t.string :error_description
      t.string :error_source
      t.string :error_step
      t.string :error_reason
      t.timestamps
    end
  end
end
