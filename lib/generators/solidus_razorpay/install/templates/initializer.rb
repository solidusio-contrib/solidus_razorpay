# frozen_string_literal: true

require 'razorpay'

SolidusRazorpay.configure do |config|
  config.razorpay_key = ENV['RAZORPAY_KEY']
  config.razorpay_secret = ENV['RAZORPAY_SECRET']
  config.razorpay_color = ENV['RAZORPAY_COLOR'] || '#3C76F0'
end

Razorpay.setup(SolidusRazorpay.configuration.razorpay_key, SolidusRazorpay.configuration.razorpay_secret);
