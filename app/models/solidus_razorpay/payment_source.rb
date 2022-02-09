# frozen_string_literal: true

require_dependency 'solidus_razorpay'

module SolidusRazorpay
  class PaymentSource < SolidusSupport.payment_source_parent_class
    enum status: { created: 0, authorized: 1, captured: 2, refunded: 3, failed: 4 }
    enum refund_status: { null: 0, partial: 1, full: 2 }
  end
end
