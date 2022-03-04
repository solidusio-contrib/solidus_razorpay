require 'spec_helper'

RSpec.describe SolidusRazorpay::Gateway, type: :model do
  let(:spree_user) { create(:user_with_addresses) }
  let(:spree_address) { spree_user.addresses.first }
  let(:order) { create(:order, bill_address: spree_address, ship_address: spree_address, user: spree_user) }
  let(:amount) { order.display_outstanding_balance.money.fractional }
  let(:receipt) { order.number }
  let(:payment_source) { create(:razorpay_payment_source) }
  let(:payment_method) { create(:razorpay_payment_method) }
  let(:payment) {
    create(:payment, order: order, source_id: payment_source.id, source_type: SolidusRazorpay::PaymentSource,
      payment_method: payment_method, response_code: nil)
  }
  let(:refund) { create(:refund, transaction_id: payment_source.razorpay_payment_id) }
  let(:gateway) {
    described_class.new({
      razorpay_key: payment_method.preferences[:razorpay_key],
      razorpay_secret: payment_method.preferences[:razorpay_secret]
    })
  }
  let(:razorpay_order) {
    Razorpay::Order.new(
      'id' => 'order_IgpDqlOTp1beGM',
      'entity' => 'order',
      'amount' => amount,
      'amount_paid': 0,
      'amount_due' => 100,
      'currency' => 'INR',
      'receipt' => receipt,
      'status' => 'created',
      'attempts' => 0,
      'notes' => []
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
      'international' => false,
      'amount_refunded' => 0,
      'refund_status' => nil,
      'captured' => false,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'error_code' => nil,
      'error_description' => nil,
      'error_source' => nil,
      'error_step' => nil,
      'error_reason' => nil,
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
      'order_id' => 'order_IgDqlOTp1beGM',
      'method' => 'card',
      'international' => false,
      'amount_refunded' => 0,
      'refund_status' => nil,
      'captured' => false,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'error_code' => nil,
      'error_description' => nil,
      'error_source' => nil,
      'error_step' => nil,
      'error_reason' => nil,
      'acquirer_data' => { 'auth_code' => '171526' }
    )
  }

  let(:razorpay_payment_unauthorized) {
    Razorpay::Payment.new(
      'id' => 'pay_IfyJVYHeAaL6AY',
      'entity' => 'payment',
      'amount' => 100,
      'currency' => 'USD',
      'base_amount' => 7560,
      'base_currency' => 'INR',
      'status' => 'failed',
      'order_id' => 'order_IgDqlOTp1beGM',
      'method' => 'card',
      'international' => false,
      'amount_refunded' => 0,
      'refund_status' => nil,
      'captured' => false,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'error_code' => nil,
      'error_description' => nil,
      'error_source' => nil,
      'error_step' => nil,
      'error_reason' => nil,
      'acquirer_data' => { 'auth_code' => '171526' }
    )
  }

  let(:razorpay_payment_refunded) {
    Razorpay::Payment.new(
      'id' => 'pay_IfyJVYHeAaL6AY',
      'entity' => 'payment',
      'amount' => 100,
      'currency' => 'USD',
      'base_amount' => 7560,
      'base_currency' => 'INR',
      'status' => 'refunded',
      'order_id' => 'order_IgDqlOTp1beGM',
      'method' => 'card',
      'international' => false,
      'amount_refunded' => 100,
      'refund_status' => 'full',
      'captured' => true,
      'description' => 'Payment to Stark Industries',
      'card_id' => 'card_IfyJVazEMj50uH',
      'email' => 'abcd@gmail.com',
      'contact' => '+121345678901',
      'fee' => 3909,
      'tax' => 0,
      'error_code' => nil,
      'error_description' => nil,
      'error_source' => nil,
      'error_step' => nil,
      'error_reason' => nil,
      'acquirer_data' => { 'auth_code' => '171526' }
    )
  }

  describe '#create_order' do
    before do
      allow(Razorpay::Order).to receive(:create) { razorpay_order }
    end

    it 'creates a razorpay order' do
      expect(gateway.create_order(amount, receipt, 'INR')).to eq razorpay_order
    end
  end

  describe '#retrieve_order' do
    before do
      allow(Razorpay::Order).to receive(:fetch) { razorpay_order }
    end

    it 'creates a razorpay order' do
      expect(gateway.retrieve_order(razorpay_order.id)).to eq razorpay_order
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

  describe '#authorize' do
    subject(:authorize) { gateway.authorize(100, payment_source, gateway_options) }

    let(:gateway_options) { { originator: payment } }

    before do
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_authorized)
    end

    it 'returns an ActiveMerchant::Billing::Response' do
      expect(authorize).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it 'returns a successfull ActiveMerchant::Billing::Response' do
      expect(authorize.success?).to be true
    end

    it 'updates the payment source status' do
      authorize
      expect(payment.source.status).to eq razorpay_payment_authorized.status
    end

    it 'updates the payment source method' do
      authorize
      expect(payment.source.method).to eq razorpay_payment_authorized.method
    end
  end

  describe '#capture' do
    subject(:capture) { gateway.capture(100, order.number, gateway_options) }

    let(:gateway_options) { { originator: payment } }

    context 'when payment is authorised' do
      before do
        allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_authorized)
        allow(razorpay_payment_authorized).to receive(:capture).and_return(razorpay_payment_captured)
      end

      it 'returns an ActiveMerchant::Billing::Response' do
        expect(capture).to be_an_instance_of(ActiveMerchant::Billing::Response)
      end

      it 'returns a successfull ActiveMerchant::Billing::Response' do
        expect(capture.success?).to be true
      end
    end

    context 'when payment is captured' do
      before do
        allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_captured)
        allow(razorpay_payment_captured).to receive(:capture).and_return(razorpay_payment_captured)
      end

      it 'returns an ActiveMerchant::Billing::Response' do
        expect(capture).to be_an_instance_of(ActiveMerchant::Billing::Response)
      end

      it 'returns a successfull ActiveMerchant::Billing::Response' do
        expect(capture.success?).to be true
      end

      it 'updates the payment source status' do
        capture
        expect(payment.source.status).to eq razorpay_payment_captured.status
      end

      it 'updates the payment source method' do
        capture
        expect(payment.source.method).to eq razorpay_payment_captured.method
      end
    end

    context 'when payment is not authorised' do
      before do
        allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_unauthorized)
      end

      it 'raises an error' do
        expect { capture }.to raise_error 'Razorpay Payment not Authorised'
      end
    end
  end

  describe '#purchase' do
    subject(:purchase) { gateway.purchase(100, payment_source, gateway_options) }

    let(:gateway_options) { { originator: payment } }

    context 'when payment is captured' do
      before do
        allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_captured)
        allow(razorpay_payment_captured).to receive(:purchase).and_return(razorpay_payment_captured)
      end

      it 'returns an ActiveMerchant::Billing::Response' do
        expect(purchase).to be_an_instance_of(ActiveMerchant::Billing::Response)
      end

      it 'returns a successfull ActiveMerchant::Billing::Response' do
        expect(purchase.success?).to be true
      end

      it 'updates the payment source status' do
        purchase
        expect(payment.source.status).to eq razorpay_payment_captured.status
      end

      it 'updates the payment source method' do
        purchase
        expect(payment.source.method).to eq razorpay_payment_captured.method
      end
    end

    context 'when payment is not authorised' do
      before do
        allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_unauthorized)
      end

      it 'raises an error' do
        expect { purchase }.to raise_error 'Razorpay Payment not Authorised'
      end
    end
  end

  describe '#void' do
    subject(:void) { gateway.void(order.number, gateway_options) }

    let(:gateway_options) { { originator: payment } }

    before do
      payment_source.update(status: 'captured')
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_refunded)
      allow(razorpay_payment_refunded).to receive(:refund)
    end

    it 'returns an ActiveMerchant::Billing::Response' do
      expect(void).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it 'returns a successfull ActiveMerchant::Billing::Response' do
      expect(void.success?).to be true
    end

    it 'updates the payment source status' do
      void
      expect(payment.source.status).to eq razorpay_payment_refunded.status
    end

    it 'updates the payment source refund_status' do
      void
      expect(payment.source.refund_status).to eq razorpay_payment_refunded.refund_status
    end
  end

  describe '#credit' do
    subject(:credit) { gateway.credit(refund.amount, payment_source.razorpay_payment_id, gateway_options) }

    let(:gateway_options) { { originator: refund } }

    before do
      payment_source.update(status: 'captured')
      allow(Razorpay::Payment).to receive(:fetch).and_return(razorpay_payment_refunded)
      allow(razorpay_payment_refunded).to receive(:refund)
    end

    it 'returns an ActiveMerchant::Billing::Response' do
      expect(credit).to be_an_instance_of(ActiveMerchant::Billing::Response)
    end

    it 'returns a successfull ActiveMerchant::Billing::Response' do
      expect(credit.success?).to be true
    end
  end
end
