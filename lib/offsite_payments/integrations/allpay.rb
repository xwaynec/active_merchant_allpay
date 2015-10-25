require 'digest/md5'
require 'net/http'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Allpay
      PAYMENT_CREDIT_CARD = 'Credit'
      PAYMENT_ATM         = 'ATM'
      PAYMENT_CVS         = 'CVS'
      PAYMENT_ALIPAY      = 'Alipay'
      PAYMENT_BARCODE     = 'BARCODE'

      SUBPAYMENT_ATM_TAISHIN      = 'TAISHIN'
      SUBPAYMENT_ATM_ESUN         = 'ESUN'
      SUBPAYMENT_ATM_HUANAN       = 'HUANAN'
      SUBPAYMENT_ATM_BOT          = 'BOT'
      SUBPAYMENT_ATM_FUBON        = 'FUBON'
      SUBPAYMENT_ATM_CHINATRUST   = 'CHINATRUST'
      SUBPAYMENT_ATM_FIRST        = 'FIRST'

      SUBPAYMENT_CVS_CVS    = 'CVS'
      SUBPAYMENT_CVS_OK     = 'OK'
      SUBPAYMENT_CVS_FAMILY = 'FAMILY'
      SUBPAYMENT_CVS_HILIFE = 'HILIFE'
      SUBPAYMENT_CVS_IBON   = 'IBON'

      PAYMENT_TYPE        = 'aio'

      mattr_accessor :service_url
      mattr_accessor :merchant_id
      mattr_accessor :hash_key
      mattr_accessor :hash_iv
      mattr_accessor :debug

      def self.service_url
        mode = ActiveMerchant::Billing::Base.mode
        case mode
          when :production
            'https://payment.allpay.com.tw/Cashier/AioCheckOut'
          when :development
            'http://payment-stage.allpay.com.tw/Cashier/AioCheckOut'
          when :test
            'http://payment-stage.allpay.com.tw/Cashier/AioCheckOut'
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
        end
      end

      def self.notification(post)
        Notification.new(post)
      end

      def self.setup
        yield(self)
      end

      class Helper < OffsitePayments::Helper
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
        mapping :notify_url, 'ReturnURL' # AM common
        # Client 端返回廠商網址
        # mapping :client_back_url, 'ClientBackURL'
        mapping :return_url, 'ClientBackURL' # AM common
        # 付款完成 redirect 的網址
        mapping :redirect_url, 'OrderResultURL'
        # 交易描述
        mapping :description, 'TradeDesc'
        # 商品銷售網址
        mapping :item_url, 'ItemURL'
        # 是否需要額外的付款資訊, defalut: N
        mapping :need_extra_paid_info, 'NeedExtraPaidInfo'
        # 裝置來源, defalut: P
        mapping :devise_source, 'DeviceSource'
        # 忽略的付款方式
        mapping :ignore_payment, 'IgnorePayment'
        # 特約合作平台商代號(由allpay提供)
        mapping :platform_id, 'PlatformID'
        # 電子發票開註記
        mapping :invoice_mark, 'InvoiceMark'
        # 是否延遲撥款, defalut: 0
        mapping :hold_trade_amt, 'HoldTradeAMT'
        # allpay 的會員編號
        mapping :allpay_id, 'AllPayID'
        # allpay 的會員識別碼
        mapping :account_id, 'AccountID'
        # CheckMacValue 加密類型, defalut: 0
        mapping :encrypt_type, 'EncryptType'
        # ATM 允許繳費有效天數
        mapping :expire_date, 'ExpireDate'
        # ATM, CVS 序號回傳網址 (Server Side)
        mapping :payment_info_url, 'PaymentInfoURL'
        # ATM, CVS 序號頁面回傳網址 (Client Side)
        mapping :payment_redirect_url, 'ClientRedirectURL'
        # BARCODE, CVS 超商繳費截止時間
        mapping :store_expire_date, 'StoreExpireDate'
        # BARCODE, CVS 交易描述1
        mapping :desc_1, 'Desc_1'
        # BARCODE, CVS 交易描述2
        mapping :desc_2, 'Desc_2'
        # BARCODE, CVS 交易描述3
        mapping :desc_3, 'Desc_3'
        # BARCODE, CVS 交易描述4
        mapping :desc_4, 'Desc_4'

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

        mapping :choose_sub_payment, 'ChooseSubPayment'

        # 商品名稱
        # 多筆請以井號分隔 (#)
        mapping :item_name, 'ItemName'

        def initialize(order, account, options = {})
          super
          add_field 'MerchantID', OffsitePayments::Integrations::Allpay.merchant_id
          add_field 'PaymentType', OffsitePayments::Integrations::Allpay::PAYMENT_TYPE
        end

        def merchant_trade_date(date)
          add_field 'MerchantTradeDate', date.strftime('%Y/%m/%d %H:%M:%S')
        end

        def encrypted_data

          raw_data = @fields.sort.map{|field, value|
            # utf8, authenticity_token, commit are generated from form helper, needed to skip
            "#{field}=#{value}" if field!='utf8' && field!='authenticity_token' && field!='commit'
          }.join('&')

          hash_raw_data = "HashKey=#{OffsitePayments::Integrations::Allpay.hash_key}&#{raw_data}&HashIV=#{OffsitePayments::Integrations::Allpay.hash_iv}"
          url_encode_data = self.class.url_encode(hash_raw_data)
          url_encode_data.downcase!

          binding.pry if OffsitePayments::Integrations::Allpay.debug

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

      class Notification < OffsitePayments::Notification
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
          when '2' # ATM 取號成功
            true
          when '10100073' # CVS 或 BARCODE 取號成功
            true
          when '800' #貨到付款訂單建立成功
            true
          else
            false
          end
        end

        def checksum_ok?
          params_copy = @params.clone

          checksum = params_copy.delete('CheckMacValue')

          # 把 params 轉成 query string 前必須先依照 hash key 做 sort
          # 依照英文字母排序，由 A 到 Z 且大小寫不敏感
          raw_data = params_copy.sort_by{ |k,v| k.downcase }.map do |x, y|
            "#{x}=#{y}"
          end.join('&')

          hash_raw_data = "HashKey=#{OffsitePayments::Integrations::Allpay.hash_key}&#{raw_data}&HashIV=#{OffsitePayments::Integrations::Allpay.hash_iv}"

          url_encode_data = OffsitePayments::Integrations::Allpay::Helper.url_encode(hash_raw_data)
          url_encode_data.downcase!

          (Digest::MD5.hexdigest(url_encode_data) == checksum.to_s.downcase)
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

        # for ATM
        def bank_code
          @params['BankCode']
        end

        def v_account
          @params['vAccount']
        end

        def expire_date
          @params['ExpireDate']
        end

        # for CVS
        def payment_no
          @params['PaymentNo']
        end

        def currency
          'TWD'
        end

        # for BARCODE
        def barcode1
          @params['Barcode1']
        end

        def barcode2
          @params['Barcode2']
        end

        def barcode3
          @params['Barcode3']
        end
      end
    end
  end
end
