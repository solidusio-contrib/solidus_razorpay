require 'spec_helper'

RSpec.describe "SolidusRazorpay::Api::Checkout", type: :request do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) { create(:order, bill_address: spree_address, ship_address: spree_address, user: spree_user) }
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

  describe 'POST /api/initialize_checkout' do
    it 'returns a successful response' do
      post '/api/initialize_checkout.json', params: {
        paymentMethodId: payment_method.id,
        orderId: order.id,
        receipt: order.number,
        amount: order.display_outstanding_balance.money.fractional
      }
      expect(response.status).to eq 200
    end

    it 'returns a the correct response body' do
      post '/api/initialize_checkout.json', params: {
        paymentMethodId: payment_method.id,
        orderId: order.id,
        receipt: order.number,
        amount: order.display_outstanding_balance.money.fractional
      }
      expect(response.body).to eq({ success: true, razorpayOrderId: razorpay_order.id,
                                    razorpayKey: payment_method.preferences[:razorpay_key] }.to_json)
    end
  end
end
