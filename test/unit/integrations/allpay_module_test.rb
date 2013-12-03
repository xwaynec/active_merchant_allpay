require 'test_helper'

class AllpayModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_notification_method
    assert_instance_of Allpay::Notification, Allpay.notification('name=cody')
  end
end
