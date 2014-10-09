#encoding: utf-8

require 'cgi'
require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Allpay
        class Helper < ActiveMerchant::Billing::Integrations::Helper

          ### 常見介面

          # 廠商編號
          mapping :merchant_id, 'MerchantID'
          mapping :account, 'MerchantID' # AM common
          # 廠商交易編號
          mapping :merchant_trade_no, 'MerchantTradeNo'
          mapping :order, 'MerchantTradeNo' # AM common
          # 交易金額
          mapping :total_amount, 'TotalAmount'
          mapping :amount, 'TotalAmount' # AM common
          # 付款完成通知回傳網址
          mapping :return_url, 'ReturnURL' # AM common
          # Client 端返回廠商網址
          mapping :client_back_url, 'ClientBackURL'
          # mapping :return_url, 'ClientBackURL' # AM common
          # 付款完成 redirect 的網址
          mapping :redirect_url, 'OrderResultURL'
          # 交易描述
          mapping :description, 'TradeDesc'
          # ATM, CVS 序號回傳網址
          mapping :payment_info_url, 'PaymentInfoURL'

          ### Allpay 專屬介面

          # 交易類型
          mapping :payment_type, 'PaymentType'

          # 選擇預設付款方式
          #   Credit:信用卡
          #   WebATM:網路 ATM
          #   ATM:自動櫃員機
          #   CVS:超商代碼
          #   BARCODE:超商條碼
          #   Alipay:支付寶
          #   Tenpay:財付通
          #   TopUpUsed:儲值消費
          #   ALL:不指定付款方式, 由歐付寶顯示付款方式 選擇頁面
          mapping :choose_payment, 'ChoosePayment'

          # 商品名稱
          # 多筆請以井號分隔 (#)
          mapping :item_name, 'ItemName'

          def initialize(order, account, options = {})
            super
            add_field 'MerchantID', ActiveMerchant::Billing::Integrations::Allpay.merchant_id
            add_field 'PaymentType', ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_TYPE
          end

          def merchant_trade_date(date)
            add_field 'MerchantTradeDate', date.strftime('%Y/%m/%d %H:%M:%S')
          end

          def encrypted_data

            raw_data = @fields.sort.map{|field, value|
              # utf8, authenticity_token, commit are generated from form helper, needed to skip
              "#{field}=#{value}" if field!='utf8' && field!='authenticity_token' && field!='commit'
            }.join('&')

            hash_raw_data = "HashKey=#{ActiveMerchant::Billing::Integrations::Allpay.hash_key}&#{raw_data}&HashIV=#{ActiveMerchant::Billing::Integrations::Allpay.hash_iv}"
            url_encode_data = self.class.url_encode(hash_raw_data)
            url_encode_data.downcase!

            binding.pry if ActiveMerchant::Billing::Integrations::Allpay.debug

            add_field 'CheckMacValue', Digest::MD5.hexdigest(url_encode_data).upcase
          end

          # Allpay .NET url encoding
          # Code based from CGI.escape()
          # Some special characters (e.g. "()*!") are not escaped on Allpay server when they generate their check sum value, causing CheckMacValue Error.
          #
          # TODO: The following characters still cause CheckMacValue error:
          #       '<', "\n", "\r", '&'
          def self.url_encode(text)
            text = text.dup
            text.gsub!(/([^ a-zA-Z0-9\(\)\!\*_.-]+)/) do
              '%' + $1.unpack('H2' * $1.bytesize).join('%')
            end
            text.tr!(' ', '+')
            text
          end
        end
      end
    end
  end
end
