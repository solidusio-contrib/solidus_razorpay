# frozen_string_literal: true

module SolidusRazorpay
  class Configuration
    # Define here the settings for this extension, e.g.:
    attr_accessor :razorpay_key, :razorpay_secret, :razorpay_test_environment
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
