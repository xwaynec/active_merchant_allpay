require 'test_helper'

class AllpayNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @allpay = Allpay::Notification.new(http_raw_data)
  end


end
