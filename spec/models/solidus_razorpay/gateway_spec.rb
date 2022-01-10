require 'spec_helper'

RSpec.describe SolidusRazorpay::Gateway, type: :model do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:gateway) { described_class.new }
  let(:order) { create(:order, bill_address: spree_address, ship_address: spree_address, user: spree_user) }
  let(:amount) { order.display_outstanding_balance.money.fractional }
  let(:receipt) { order.number }
  let(:payment) { create(:payment, response_code: nil) }
  let(:payment_source) { create(:razorpay_payment_source, order: order) }
  let(:razorpay_order) {
    Razorpay::Order.new(
      'id' => 'order_IgpDqlOTp1beGM',
      'entity' => 'order',
      'amount' => amount,
      'amount_paid': 0,
      'amount_due' => 100,
      'currency' => gateway.class::CURRENCY,
      'receipt' => receipt,
      'status' => 'created',
      'attempts' => 0,
      'notes' => []
    )
  }
  let(:razorpay_payment_captured) {
    Razorpay::Payment.new(
      'id' => 'pay_IfyJVYHeAaL6AY',
      'entity' => 'payment',
      'amount' => 100,
      'currency' => 'USD',
      'base_amount' => 7560,
      'base_currency' => 'INR',
      'status' => 'captured',
      'order_id' => 'order_gpDqlOTp1beGM',
      'method' => 'card',
      'amount_refunded' => 0,
      'refund_status' => nil,
      'captured' => true,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'acquirer_data' => { 'auth_code' => '171526' }
    )
  }
  let(:razorpay_payment_authorized) {
    Razorpay::Payment.new(
      'id' => 'pay_IfyJVYHeAaL6AY',
      'entity' => 'payment',
      'amount' => 100,
      'currency' => 'USD',
      'base_amount' => 7560,
      'base_currency' => 'INR',
      'status' => 'authorized',
      'order_id' => 'order_IgDqlOTp1beGM',
      'method' => 'card',
      'amount_refunded' => 0,
      'refund_status' => nil,
      'captured' => false,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'acquirer_data' => { 'auth_code' => '171526' }
    )
  }
  let(:razorpay_payment_response) {
    Razorpay::Payment.new(
      'id' => 'pay_IfyJVYHeAaL6AY',
      'entity' => 'payment',
      'amount' => 100,
      'currency' => 'USD',
      'base_amount' => 7560,
      'base_currency' => 'INR',
      'status' => 'captured',
      'order_id' => 'order_IgDqlOTp1beGM',
      'method' => 'card',
      'amount_refunded' => 0,
      'refund_status' => nil,
      'captured' => true,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'card' => {
        'id' => 'card_Ifx2egIqLbumMB',
        'entity' => 'card',
        'name' => 'Peter Parker',
        'last4' => '1111',
        'network' => 'Visa',
        'type' => 'debit',
        'sub_type' => 'consumer'
      },
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'acquirer_data' => { 'auth_code' => '171526' }
    )
  }

  before do
    payment.source = payment_source
  end

  describe '#create_order' do
    before do
      allow(Razorpay::Order).to receive(:create).and_return(razorpay_order)
    end

    it 'creates a razorpay order' do
      expect(gateway.create_order(amount, receipt)).to eq razorpay_order
    end
  end

  describe '#retrieve_order' do
    subject(:retrieved_order) { gateway.retrieve_order('order_IgpDqlOTp1beGM') }

    before do
      allow(Razorpay::Order).to receive(:fetch).and_return(razorpay_order)
    end

    it 'retrieves a order from Razorpay' do
      expect(retrieved_order).to eq razorpay_order
    end

    it 'retrieves the correct id from Razorpay' do
      expect(retrieved_order.id).to eq 'order_IgpDqlOTp1beGM'
    end
  end

  describe '#retrieve_payment' do
    subject(:retrieved_payment) { gateway.retrieve_payment('pay_IfyJVYHeAaL6AY') }

    before do
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_response)
    end

    it 'retrieves a payment from Razorpay' do
      expect(retrieved_payment).to eq razorpay_payment_response
    end

    it 'retrieves the correct id from Razorpay' do
      expect(retrieved_payment.id).to eq 'pay_IfyJVYHeAaL6AY'
    end
  end

  describe '#capture_payment failure' do
    it 'throws an error if payment is not authorized' do
      expect { gateway.capture_payment(razorpay_payment_captured, 100) }.to raise_error('Razorpay Payment Unauthorized')
    end
  end

  describe '#capture_payment success' do
    subject(:captured_payment) { gateway.capture_payment(razorpay_payment_authorized, 100) }

    before do
      allow(razorpay_payment_authorized).to receive(:capture).and_return(razorpay_payment_response)
    end

    it 'captures payment successfully' do
      expect(captured_payment.status).to eq 'captured'
    end

    it 'sets the capture attribute to true' do
      expect(captured_payment.captured).to eq true
    end
  end

  describe '#void' do
    subject(:void) { gateway.void(nil, gateway_options) }

    let(:gateway_options) { { originator: payment } }

    before do
      payment_source.razorpay_payment_id = razorpay_payment_authorized.id
      payment.source = payment_source
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_authorized)
      void
    end

    it "returns an ActiveMerchant::Billing::Response " do
      expect(void).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it "returns a successfull ActiveMerchant::Billing::Response" do
      expect(void.success?).to be true
    end

    it 'returns a failed ActiveMerchant::Billing::Response' do
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_captured)
      expect(gateway.void(nil, gateway_options).success?).to be false
    end
  end

  describe '#authorize' do
    subject(:authorize) { gateway.authorize(100, nil, gateway_options) }

    let(:gateway_options) { { originator: payment } }

    before do
      payment_source.razorpay_payment_id = razorpay_payment_authorized.id
      payment.source = payment_source
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_authorized)
      authorize
    end

    it "returns an ActiveMerchant::Billing::Response " do
      expect(authorize).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it "returns a successfull ActiveMerchant::Billing::Response" do
      expect(authorize.success?).to be true
    end
  end
end
