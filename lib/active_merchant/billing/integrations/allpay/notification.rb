require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Allpay
        class Notification < ActiveMerchant::Billing::Integrations::Notification

          def status
            if rtn_code == '1'
              true
            else
              false
            end
          end

          def checksum_ok?
            checksum = @params.delete('CheckMacValue')

            @params.delete('controller')
            @params.delete('action')

            # 把 params 轉成 query string 前必須先依照 hash key 做 sort
            raw_data = Hash[@params.sort].map do |x, y|
              "#{x}=#{y}"
            end.join('&')

            hash_raw_data = "HashKey=#{ActiveMerchant::Billing::Integrations::Allpay.hash_key}&#{raw_data}&HashIV=#{ActiveMerchant::Billing::Integrations::Allpay.hash_iv}"

            url_endcode_data = (CGI::escape(hash_raw_data)).downcase

            (Digest::MD5.hexdigest(url_endcode_data) == checksum.to_s.downcase)
          end

          def rtn_code
            @params['RtnCode']
          end

          def merchant_id
            @params['MerchantID']
          end

          def merchant_trade_no
            @params['MerchantTradeNo']
          end

          def rtn_msg
            @params['RtnMsg']
          end

          def trade_no
            @params['TradeNo']
          end

          def trade_amt
            @params['TradeAmt']
          end

          def payment_date
            @params['PaymentDate']
          end

          def payment_type
            @params['PaymentType']
          end

          def payment_type_charge_fee
            @params['PaymentTypeChargeFee']
          end

          def trade_date
            @params['TradeDate']
          end

          def simulate_paid
            @params['SimulatePaid']
          end

          def check_mac_value
            @params['CheckMacValue']
          end

        end
      end
    end
  end
end
