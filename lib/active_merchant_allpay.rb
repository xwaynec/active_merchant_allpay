require "active_merchant_allpay/version"
require "active_merchant"
require 'offsite_payments'

module OffsitePayments
  module Integrations
    autoload :Allpay, 'offsite_payments/integrations/allpay'
  end
end
