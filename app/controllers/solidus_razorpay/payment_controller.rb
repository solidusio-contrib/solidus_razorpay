class SolidusRazorpay::PaymentController < ::Spree::BaseController
  include Spree::Core::ControllerHelpers::Order

  before_action :load_order

  def razorpay_checkout
    authorize! :update, @order, cookies.signed[:guest_token]
    amount = @order.display_outstanding_balance.money.fractional
    receipt = @order.number
    @razorpay_order = Razorpay::Order.create(amount: amount, currency: Razorpay::Gateway::CURRENCY, receipt: receipt)
  end

  private

    def load_order
      @order = current_order
    end
end
