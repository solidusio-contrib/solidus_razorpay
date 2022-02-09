# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusRazorpay
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_razorpay'

    initializer "solidus_razorpay.add_static_preference", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << SolidusRazorpay::RazorpayPayment
      Spree::Config.static_model_preferences.add(
        SolidusRazorpay::RazorpayPayment,
        'razorpay_credentials', {
          razorpay_key: ENV['RAZORPAY_KEY'],
          razorpay_secret: ENV['RAZORPAY_SECRET'],
          razorpay_test_environment: ENV['RAZORPAY_TEST_ENV'],
        }
      )
      Spree::PermittedAttributes.source_attributes.concat [
        :razorpay_order_id,
        :razorpay_payment_id,
        :currency,
        :method,
        :status,
        :amount_refunded,
        :refund_status,
        :captured,
        :amount,
        :international,
        :error_code,
        :error_description,
        :error_source,
        :error_step,
        :error_reason
      ]
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
