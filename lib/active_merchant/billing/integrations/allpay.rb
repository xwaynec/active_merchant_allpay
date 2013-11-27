require File.dirname(__FILE__) + '/allpay/helper.rb'
require File.dirname(__FILE__) + '/allpay/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Allpay
        autoload :Helper, 'active_merchant/billing/integrations/allpay/helper.rb'
        autoload :Notification, 'active_merchant/billing/integrations/allpay/notification.rb'

        PAYMENT_CREDIT_CARD = 'Credit'
        PAYMENT_ATM         = 'ATM'
        PAYMENT_CVS         = 'CVS'

        PAYMENT_TYPE        = 'aio'

        mattr_accessor :service_url
        mattr_accessor :merchant_id
        mattr_accessor :hash_key
        mattr_accessor :hash_iv

        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
            when :production
              'https://payment.allpay.com.tw/Cashier/AioCheckOut'
            when :development
              'http://payment-stage.allpay.com.tw/Cashier/AioCheckOut'
            when :test
              'http://payment-stage.allpay.com.tw/Cashier/AioCheckOut'
            else
              raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.notification(post)
          Notification.new(post)
        end

        def self.setup
          yield(self)
        end

      end
    end
  end
end
