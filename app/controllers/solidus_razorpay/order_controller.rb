class SolidusRazorpay::OrderController < ::Spree::BaseController
  protect_from_forgery unless: -> { request.format.json? }

  def index
    receipt = params[:receipt]
    amount = params[:amount]
    order_id = params[:orderId]
    gateway = SolidusRazorpay::Gateway.new
    razorpay_order = gateway.create_order(amount, receipt)
    payment_source = SolidusRazorpay::PaymentSource.new(
                      order_id: order_id,
                      razorpay_order_id: razorpay_order.id,
                      currency: razorpay_order.currency,
                      order_status: razorpay_order.status,
                      amount: razorpay_order.amount,
                      amount_due: razorpay_order.amount_due,
                      amount_paid: razorpay_order.amount_paid
                    )
    payment_source.save
    respond_to do |format|
      format.json { render json: { success: true, razorpayOrderId: razorpay_order.id, paymentSourceId: payment_source.id } }
    end
  rescue StandardError => e
    error_message = e.to_s
    logger.error error_message
    respond_to do |format|
      format.json { render json:  { success: false } }
    end
  end
end
