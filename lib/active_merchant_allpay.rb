require "active_merchant_allpay/version"
require "active_merchant"

module ActiveMerchant
  module Billing
    module Integrations
      autoload :Allpay, 'active_merchant/billing/integrations/allpay'
    end
  end
end