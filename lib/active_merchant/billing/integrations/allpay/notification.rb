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

          # TODO 使用查詢功能實作 acknowledge
          # Allpay 沒有遠端驗證功能，
          # 而以 checksum_ok? 代替
          def acknowledge
            checksum_ok?
          end

          def complete?
            case @params['RtnCode']
            when '1' #付款成功
              true
            when '800' #貨到付款訂單建立成功
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

          # 廠商交易編號
          def merchant_trade_no
            @params['MerchantTradeNo']
          end
          alias :item_id :merchant_trade_no

          def rtn_msg
            @params['RtnMsg']
          end

          # AllPay 的交易編號
          def trade_no
            @params['TradeNo']
          end
          alias :transaction_id :trade_no

          def trade_amt
            @params['TradeAmt']
          end
          def gross
            ::Money.new(@params['TradeAmt'].to_i * 100, currency)
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

          def currency
            'TWD'
          end
        end
      end
    end
  end
end
