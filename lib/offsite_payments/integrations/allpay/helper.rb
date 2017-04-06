require 'digest/md5'

module OffsitePayments #:nodoc:
  module Integrations #:nodoc:
    module Allpay
      class Helper < OffsitePayments::Helper
        ### 預設介面

        # 廠商編號(由 allpay 提供)
        # type: Varchar(10)
        # presense: true
        # example: 2000132
        # description:
        mapping :merchant_id, 'MerchantID'
        mapping :account, 'MerchantID' # AM common

        # 廠商交易編號
        # type: Varchar(20)
        # presense: true
        # example: allpay1234
        # description: 廠商交易編號不可重覆。英數字大小寫混合
        mapping :merchant_trade_no, 'MerchantTradeNo'
        mapping :order, 'MerchantTradeNo' # AM common

        # 廠商交易時間
        # type: Varchar(20)
        # presense: true
        # example: 2012/03/21 15:40:18
        # description: 格式為:yyyy/MM/dd HH:mm:ss
        mapping :merchant_trade_date, 'MerchantTradeDate'

        # 交易類型
        # type: Varchar(20)
        # presense: true
        # example: aio
        # description: 請帶 aio
        mapping :payment_type, 'PaymentType'

        # 交易金額
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :total_amount, 'TotalAmount'
        mapping :amount, 'TotalAmount' # AM common

        # 交易描述
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :description, 'TradeDesc'

        # 商品名稱
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :item_name, 'ItemName'

        # 付款完成通知回傳網址
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :notify_url, 'ReturnURL' # AM common

        # 選擇預設付款方式
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :choose_payment, 'ChoosePayment'

        # 檢查碼
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :check_mac_value, 'CheckMacValue'

        # Client 端返回廠商網址
        # type: Varchar(20)
        # presense: true
        # example:
        # description:
        mapping :client_back_url, 'ClientBackURL'
        mapping :return_url, 'ClientBackURL' # AM common

        # 商品銷售網址
        mapping :item_url, 'ItemURL'

        # 備註欄位。
        mapping :remark, 'Remark'

        # 選擇預設付款子項目
        mapping :choose_sub_payment, 'ChooseSubPayment'

        # 付款完成 redirect 的網址
        mapping :redirect_url, 'OrderResultURL'

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

        # CheckMacValue 加密類型, defalut: 0
        mapping :encrypt_type, 'EncryptType'

        ### ChoosePayment 為 ATM/CVS/BARCODE

        # ATM, CVS 序號回傳網址 (Server Side)
        mapping :payment_info_url, 'PaymentInfoURL'
        # ATM, CVS 序號頁面回傳網址 (Client Side)
        mapping :client_redirect_url, 'ClientRedirectURL'
        mapping :payment_redirect_url, 'ClientRedirectURL'

        ### ATM

        # ATM 允許繳費有效天數
        mapping :expire_date, 'ExpireDate'

        ### CVS/BARCODE

        # 超商繳費截止時間
        mapping :store_expire_date, 'StoreExpireDate'
        # 交易描述1
        mapping :desc_1, 'Desc_1'
        # 交易描述2
        mapping :desc_2, 'Desc_2'
        # 交易描述3
        mapping :desc_3, 'Desc_3'
        # 交易描述4
        mapping :desc_4, 'Desc_4'

        ### Alipay
        mapping :alipay_item_name, 'AlipayItemName'
        mapping :alipay_item_counts, 'AlipayItemCounts'
        mapping :alipay_item_price, 'AlipayItemPrice'
        mapping :email, 'Email'
        mapping :phone_no, 'PhoneNo'
        mapping :uder_name, 'UserName'
        mapping :expire_time, 'ExpireTime'

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
