# frozen_string_literal: true

module SolidusRazorpay
  class PaymentSource < SolidusSupport.payment_source_parent_class
    self.table_name = 'solidus_razorpay_payment_sources'
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :payment_method, class_name: 'Spree::PaymentMethod'

    enum order_status: { created: 0, attempted: 1, paid: 2 }, _suffix: true
    enum payment_status: { not_started: 0, created: 1, authorized: 2, captured: 3, refunded: 4, failed: 5 },
      _suffix: true

    def receipt
      order.number
    end
  end
end
