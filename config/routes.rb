# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  post '/api/initialize_checkout', to: '/solidus_razorpay/api/checkout#index', as: 'razorpay_initialize_checkout'
end
