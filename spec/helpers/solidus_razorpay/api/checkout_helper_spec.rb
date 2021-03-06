require 'spec_helper'

RSpec.describe SolidusRazorpay::Api::CheckoutHelper, type: :helper do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) {
    create(
      :order,
      bill_address: spree_address,
      ship_address: spree_address,
      user: spree_user
    )
  }
  let(:order_with_razorpay) {
    create(
      :order,
      bill_address: spree_address,
      ship_address: spree_address,
      user: spree_user,
      razorpay_order_id: 'order_IgpDqlOTp1beGM'
    )
  }
  let(:amount) { order.display_outstanding_balance.money.fractional }
  let(:payment_method) { create(:razorpay_payment_method) }
  let(:razorpay_order) {
    Razorpay::Order.new(
      'id' => 'order_IgpDqlOTp1beGM',
      'entity' => 'order',
      'amount' => amount,
      'amount_paid': 0,
      'amount_due' => 100,
      'currency' => 'INR',
      'receipt' => order.number,
      'status' => 'created',
      'attempts' => 0,
      'notes' => []
    )
  }

  before do
    allow(Razorpay::Order).to receive(:create) { razorpay_order }
  end

  describe '#create_order' do
    context 'when order does not have a razorpay_order_id' do
      subject(:response) { create_order(params, payment_method) }

      let(:params) { { orderId: order.id, amount: amount, receipt: order.number } }

      it 'successfully returns a Razorpay::Order object' do
        expect(response.class).to eq Razorpay::Order
      end

      it 'returns the correct order id in the object' do
        expect(response.id).to eq 'order_IgpDqlOTp1beGM'
      end
    end

    context 'when order has a razorpay_order_id' do
      subject(:response) { create_order(params, payment_method) }

      let(:params) { { orderId: order_with_razorpay.id, amount: amount, receipt: order_with_razorpay.number } }

      before do
        allow(Razorpay::Order).to receive(:fetch) { razorpay_order }
      end

      it 'successfully returns a Razorpay::Order object' do
        expect(response.class).to eq Razorpay::Order
      end

      it 'returns the correct order id in the object' do
        expect(response.id).to eq 'order_IgpDqlOTp1beGM'
      end
    end
  end
end
