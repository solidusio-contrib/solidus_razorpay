# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusRazorpay
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_razorpay'

    initializer "solidus_razorpay.add_static_preference", after: "spree.register.payment_methods" do |app|
      Spree::Config.static_model_preferences.add(
        SolidusRazorpay::PaymentMethod,
        'razorpay_credentials', {
          razorpay_key: SolidusRazorpay.configuration.razorpay_key,
          razorpay_secret: SolidusRazorpay.configuration.razorpay_secret
        }
      )

      app.config.spree.payment_methods << SolidusRazorpay::PaymentMethod
      Spree::PermittedAttributes.source_attributes.concat [:order_id, :razorpay_order_id, :razorpay_payment_id, :razorpay_signature]
    end
    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
