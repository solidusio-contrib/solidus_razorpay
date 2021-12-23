class SolidusRazorpay::OrderController < ::Spree::BaseController
  include Spree::Core::ControllerHelpers::Order

  before_action :load_order

  def index
    receipt = params[:receipt]
    amount = params[:amount]
    gateway = SolidusRazorpay::Gateway.new
    razorpay_order = gateway.create_order(amount, receipt)
    SolidusRazorpay::PaymentSource.new(
      order_id: @order.id,
      razorpay_order_id: razorpay_order.id,
      currency: razorpay_order.currency,
      order_status: razorpay_order.status,
      amount: razorpay_order.amount,
      amount_due: razorpay_order.amount_due,
      amount_paid: razorpay_order.amount_paid
    ).save

    render json: { success: true, orderId: razorpay_order.id}
  rescue StandardError => e
    error_message = e.to_s
    logger.error error_message
    render json: { success: false }
  end

  private

    def load_order
      @order = current_order
    end
end
