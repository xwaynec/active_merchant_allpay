# ActiveMerchantAllpay

This plugin is an active_merchant patch forAllpay(歐付寶) online payment in Taiwan.
Now it supports Credit card(信用卡), ATM(虛擬ATM) and CVS(超商繳費).

## Installation

Add this line to your application's Gemfile:

    gem 'activemerchant'
    gem 'active_merchant_allpay'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activemerchant
    $ gem install active_merchant_allpay

## Usage

You can get Payment API and SPEC in [Allpay API](http://www.allpay.com.tw/Service/API).
Then create an initializer, like initializers/allpay.rb. Add the following configurations depends on your settings.

``` ruby
ActiveMerchant::Billing::Integrations::Allpay.setup do |allpay|
  if Rails.env.development?
    allpay.merchant_id = '5566183'
    allpay.hash_key    = '56cantdieohyeah'
    allpay.hash_iv     = '183club'
  else
    allpay.merchant_id = '7788520'
    allpay.hash_key    = 'adfas123412343j'
    allpay.hash_iv     = '123ddewqerasdfas'
  end
end
```

## Example Usage

Now support three payment methods:

``` ruby
  # 1. Credit card
  ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_CREDIT_CARD

  # 2. ATM
  ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_ATM

  # 3. CVS (convenience store)
  ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_CVS
```

Once you’ve configured ActiveMerchantAllpay, you need a checkout form; it looks like:

``` ruby
  <% payment_service_for  @order,
                          @order.user.email,
                          :service => :allpay,
                          :html    => { :id => 'allpay-atm-form', :method => :post } do |service| %>

    <% service.merchant_trade_no @order.payments.last.identifier %>
    <% service.merchant_trade_date @order.created_at %>
    <% service.total_amount @order.total.to_i %>
    <% service.trade_desc @order.number %>
    <% service.item_name @order.number %>
    <% service.choose_payment ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_ATM %>
    <% service.client_back_url spree.orders_account_url %>
    <% service.return_url allpay_atm_return_url %>
    <% service.encrypted_data %>
    <%= submit_tag 'Buy!' %>
  <% end %>
```

Also need a notification action when Allpay service notifies your server; it looks like:

``` ruby
  def notify
    notification = ActiveMerchant::Billing::Integrations::Allpay::Notification.new(params)

    order = Order.find_by_number(notification.merchant_trade_no)

    if notification.status && notification.checksum_ok?
      # payment is compeleted
    else
      # payment is failed
    end

    render text: '1|OK', status: 200
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

