# frozen_string_literal: true

module SolidusRazorpay
  class Configuration
    attr_accessor :razorpay_key, :razorpay_secret
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
