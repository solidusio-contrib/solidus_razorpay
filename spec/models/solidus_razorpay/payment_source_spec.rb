require 'spec_helper'

RSpec.describe SolidusRazorpay::PaymentSource, type: :model do
  let(:column_list) {
    [
      'id',
      'payment_method_id',
      'razorpay_order_id',
      'razorpay_payment_id',
      'currency',
      'method',
      'status',
      'amount_refunded',
      'refund_status',
      'captured',
      'amount',
      'international',
      'error_code',
      'error_description',
      'error_source',
      'error_step',
      'error_reason',
      'created_at',
      'updated_at'
    ]
  }

  describe 'Check Model Integrity' do
    it 'has correct table name' do
      expect(described_class.table_name).to eq 'solidus_razorpay_payment_sources'
    end

    it 'has correct attributes' do
      expect(described_class.new.attributes.keys).to eq column_list
    end
  end
end
