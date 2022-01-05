class CreateSolidusRazorpayPaymentSources < ActiveRecord::Migration[6.1]
  def change
    create_table :solidus_razorpay_payment_sources do |t|
      t.references :order, index: true, foreign_key: { to_table: :spree_orders }
      t.integer :payment_method_id, index: true
      t.string :razorpay_order_id, null: false
      t.string :razorpay_payment_id
      t.string :currency
      t.string :method
      t.string :order_status, default: 0
      t.string :payment_status, default: 0
      t.integer :amount
      t.integer :amount_paid
      t.integer :amount_due
      t.integer :payment_attempts
      t.string :razorpay_signature
      t.timestamps
    end

    add_foreign_key :solidus_razorpay_payment_sources, :spree_payment_methods, column: :payment_method_id
  end
end
