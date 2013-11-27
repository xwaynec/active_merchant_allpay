#encoding: utf-8

require 'cgi'
require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Allpay
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          mapping :merchant_id, 'MerchantID'
          mapping :merchant_trade_no, 'MerchantTradeNo'
          mapping :payment_type, 'PaymentType'
          mapping :total_amount, 'TotalAmount'
          mapping :return_url, 'ReturnURL'
          mapping :client_back_url, 'ClientBackURL'
          mapping :choose_payment, 'ChoosePayment'

          def initialize(order, account, options = {})
            super
            add_field 'MerchantID', ActiveMerchant::Billing::Integrations::Allpay.merchant_id
            add_field 'PaymentType', ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_TYPE
          end

          def merchant_trade_no(trade_number)
            add_field 'MerchantTradeNo', trade_number
          end

          def merchant_trade_date(date)
            add_field 'MerchantTradeDate', date.strftime('%Y/%m/%d %H:%M:%S')
          end

          def total_amount(amount)
            add_field 'TotalAmount', amount
          end

          def trade_desc(description)
            add_field 'TradeDesc', description
          end

          def item_name(item)
            add_field 'ItemName', item
          end

          def choose_payment(payment)
            add_field 'ChoosePayment', payment
          end

          def return_url(url)
            add_field 'ReturnURL', url
          end

          def client_back_url(url)
            add_field 'ClientBackURL', url
          end

          def encrypted_data

            hash_data = {
              :ChoosePayment => @fields['ChoosePayment'],
              :ClientBackURL => @fields['ClientBackURL'],
              :ItemName => @fields['ItemName'],
              :MerchantID => @fields['MerchantID'],
              :MerchantTradeDate => @fields['MerchantTradeDate'],
              :MerchantTradeNo => @fields['MerchantTradeNo'],
              :PaymentType => @fields['PaymentType'],
              :ReturnURL => @fields['ReturnURL'],
              :TotalAmount => @fields['TotalAmount'],
              :TradeDesc => @fields['TradeDesc']
            }

            raw_data = hash_data.map do |x, y|
              "#{x}=#{y}"
            end.join('&')

            hash_raw_data = "HashKey=#{ActiveMerchant::Billing::Integrations::Allpay.hash_key}&#{raw_data}&HashIV=#{ActiveMerchant::Billing::Integrations::Allpay.hash_iv}"

            url_endcode_data = (CGI::escape(hash_raw_data)).downcase

            add_field 'CheckMacValue', Digest::MD5.hexdigest(url_endcode_data)
          end

        end
      end
    end
  end
end
