# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  mount SolidusRazorpay::Engine, at: '/solidus_razorpay'
  # Add your extension routes here
  get 'razorpay_checkout', to: '/solidus_razorpay/payment#razorpay_checkout'
  get 'razorpay_complete_checkout', to: '/solidus_razorpay/payment#complete_checkout'
  get 'razorpay_payment', to: '/solidus_razorpay/payment#index'
  get 'razorpay_order', to: '/solidus_razorpay/order#index'

end
