class SolidusRazorpay::PaymentSource < SolidusSupport.payment_source_parent_class
  self.table_name = 'solidus_razorpay_payment_sources'
  belongs_to :order, class_name: 'Spree::Order'
  belongs_to :payment_method, class_name: 'Spree::PaymentMethod'
  # validates :order_id, presence: true

  enum order_status: %i[created attempted paid], _suffix: true
  enum payment_status: %i[not_started created authorized captured refunded failed], _suffix: true

  def receipt
    order.number
  end
end
