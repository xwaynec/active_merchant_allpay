require 'digest/md5'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Allpay
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
    end
  end
end
