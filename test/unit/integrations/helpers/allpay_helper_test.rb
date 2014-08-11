require 'test_helper'

class AllpayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
  end

  def test_check_mac_value
    @helper = Allpay::Helper.new 'sdfasdfa', '12345678'
    @helper.add_field 'ItemName', 'sdfasdfa'
    @helper.add_field 'MerchantID', '12345678'
    @helper.add_field 'MerchantTradeDate', '2013/03/12 15:30:23'
    @helper.add_field 'MerchantTradeNo','allpay_1234'
    @helper.add_field 'PaymentType', 'allpay'
    @helper.add_field 'ReturnURL', 'http:sdfasdfa'
    @helper.add_field 'TotalAmount', '500'
    @helper.add_field 'TradeDesc', 'dafsdfaff'

    ActiveMerchant::Billing::Integrations::Allpay.hash_key = 'xdfaefasdfasdfa32d'
    ActiveMerchant::Billing::Integrations::Allpay.hash_iv = 'sdfxfafaeafwexfe'

    @helper.encrypted_data

    assert_equal '40D9A6C00A4A78A300ED458237071BDA', @helper.fields['CheckMacValue']
  end
end
