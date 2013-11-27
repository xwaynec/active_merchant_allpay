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

            raw_data = @params.map do |x, y|
              "#{x}=#{y}"
            end.join('&')

            hash_raw_data = "HashKey=#{ActiveMerchant::Billing::Integrations::Allpay.hash_key}&#{raw_data}&HashIV=#{ActiveMerchant::Billing::Integrations::Allpay.hash_iv}"

            url_endcode_data = (CGI::escape(hash_raw_data)).downcase

            (Digest::MD5.hexdigest(url_endcode_data) == checksum.to_s.downcase)
          end

          def initialize(params)
            self.params = params
          end

          def params=(params)
            @params = params.inject({}) do |buffer, (name, value)|
              buffer.merge(name.to_s => value)
            end
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

          private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post.to_s
            for line in @raw.split('&')
              key, value  = *line.scan(%r{^([A-Za-z0-9_.]+)\=(.*)$}).flatten
              params[key] = CGI.unescape(value)
            end
          end

        end
      end
    end
  end
end
