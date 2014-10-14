# ActiveMerchantAllpay

This plugin is an active_merchant patch forAllpay(歐付寶) online payment in Taiwan.
Now it supports Credit card(信用卡), ATM(虛擬ATM), Alipay(支付寶) and CVS(超商繳費).

It has been tested on Rails 4.1.6 successfully.

## Installation

Add this line to your application's Gemfile:

    gem 'activemerchant', "~> 1.43.3"
    gem 'active_merchant_allpay', '>=0.1.2'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activemerchant
    $ gem install active_merchant_allpay

## Usage

You can get Payment API and SPEC in [Allpay API](http://www.allpay.com.tw/Service/API).
Then create an initializer, like initializers/allpay.rb. Add the following configurations depends on your settings.

``` ruby

# config/environments/development.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.integration_mode = :development
end

# config/environments/production.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.integration_mode = :production
end

```

``` ruby

# initializers/allpay.rb
ActiveMerchant::Billing::Integrations::Allpay.setup do |allpay|
  if Rails.env.development?
    # default setting for stage test
    allpay.merchant_id = '2000132'
    allpay.hash_key    = '5294y06JbISpM5x9'
    allpay.hash_iv     = 'v77hoKGq4kWxNNIS'
  else
    # change to yours
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
  
  # 4. Alipay
  ActiveMerchant::Billing::Integrations::Allpay::PAYMENT_ALIPAY
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
    <% service.notify_url allpay_atm_return_url %>
    <% service.encrypted_data %>
    <%= submit_tag 'Buy!' %>
  <% end %>
```

Also need a notification action when Allpay service notifies your server; it looks like:

``` ruby
  def notify
    notification = ActiveMerchant::Billing::Integrations::Allpay::Notification.new(request.raw_post)

    order = Order.find_by_number(notification.merchant_trade_no)

    if notification.status && notification.checksum_ok?
      # payment is compeleted
    else
      # payment is failed
    end

    render text: '1|OK', status: 200
  end
```

## Troublechooting
If you get a error "undefined method \`payment\_service\_for\`", you can add following configurations to initializers/allpay.rb. 
```
require "active_merchant/billing/integrations/action_view_helper"
ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)
```

Some allpay error due to CSRF token ("authenticity_token is not in spec"), you can add following scripts to remove them manually.
```
<script>
$("input[name=utf8]").remove();
$("input[name=authenticity_token]").remove();
</script>
```
It's caused from payment\_service\_for helper function when generating by [offsite_payments](https://github.com/Shopify/offsite_payments) gem (offsite\_payments/lib/offsite\_payments/action\_view\_helper.rb)
  

## Upgrade Notes

When upgrading from 0.1.3 and below to any higher versions, you need to make the following changes:

- the notification initialize with raw post string (instead of a hash of params)
- `return_url()` should be renamed to `notify_url()` (server-side callback url).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

