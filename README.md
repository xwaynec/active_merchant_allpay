# ActiveMerchantAllpay

This plugin is an active_merchant patch for Allpay(歐付寶) online payment in Taiwan.
Now it supports:
 - Credit card(信用卡)
 - ATM(虛擬ATM)
 - Alipay(支付寶)
 - CVS(超商繳費)
 - BARCODE(超商條碼).

It has been tested on Rails 4.2 successfully.

## Installation

Add this line to your application's Gemfile:
``` Gemfile
gem 'active_merchant_allpay', github: 'imgarylai/active_merchant_allpay'
```
And then execute:
```sh
$ bundle install
```
Or install it yourself as:
```
$ gem install active_merchant_allpay
```

## Usage

You can get Payment API and SPEC in [Allpay API](https://www.allpay.com.tw/Service/API_Help).
Then create an initializer, like initializers/allpay.rb. Add the following configurations depends on your settings.

``` ruby
# config/environments/development.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :development
end

# config/environments/production.rb
config.after_initialize do
  ActiveMerchant::Billing::Base.mode = :production
end

```

``` ruby
# initializers/allpay.rb
OffsitePayments::Integrations::Allpay.setup do |allpay|
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

``` rb
# 1. Credit card
OffsitePayments::Integrations::Allpay::PAYMENT_CREDIT_CARD

# 2. ATM
OffsitePayments::Integrations::Allpay::PAYMENT_ATM

# 3. CVS (convenience store)
OffsitePayments::Integrations::Allpay::PAYMENT_CVS

# 4. Alipay
OffsitePayments::Integrations::Allpay::PAYMENT_ALIPAY

# 5. BARCODE
OffsitePayments::Integrations::Allpay::PAYMENT_BARCODE
```

Once you’ve configured ActiveMerchantAllpay, you need a checkout form; it looks like:

``` erb
<% payment_service_for  @order.id,
                        @order.user.email,
                        :service => :allpay,
                        :html    => { :id => 'allpay-atm-form', :method => :post } do |service| %>
  <% service.merchant_trade_no "#{@order.id}T#{Time.zone.now}" %>
  <% service.merchant_trade_date @order.created_at %>
  <% service.total_amount @order.total.to_i %>
  <% service.description @order.id %>
  <% service.item_name @order.id %>
  <% service.choose_payment OffsitePayments::Integrations::Allpay::PAYMENT_ATM %>
  <% service.return_url root_path %>
  <% service.notify_url allpay_atm_return_url %>
  <% service.encrypted_data %>
  <%= submit_tag 'Buy!' %>
<% end %>
```

Also need a notification action when Allpay service notifies your server; it looks like:

``` ruby
def notify
  notification = OffsitePayments::Integrations::Allpay::Notification.new(request.raw_post)

  order = Order.find_by_number(notification.merchant_trade_no)

  if notification.status && notification.checksum_ok?
    # payment is compeleted
  else
    # payment is failed
  end

  render text: '1|OK', status: 200
end
```

## Multiple Merchant Id (dynamic merchant id)

You don't need to setup `merchant_id` `hash_key` `hash_iv` in `initializers/*.rb`. setup those data in form helper like below:

``` erb
<% payment_service_for  @order.id,
                        @order.user.email,
                        :service => :allpay,
                        :html    => { :id => 'allpay-atm-form', :method => :post } do |service| %>
  <% service.merchant_trade_no "#{@order.id}T#{Time.zone.now}" %>
  <% service.merchant_id "YOUR MERCHANT_ID HERE" %>
  <!--
    hash iv and hash key will not show in HTML
    those settings only for encrypted_data
   -->
  <% service.hash_key "YOUR HASH KEY HERE" %>
  <% service.hash_iv "YOUR HASH IV HERE" %>
  <% service.total_amount @order.total.to_i %>
  <% service.description @order.id %>
  <% service.item_name @order.id %>
  <% service.choose_payment OffsitePayments::Integrations::Allpay::PAYMENT_ATM %>
  <% service.return_url root_path %>
  <% service.notify_url allpay_atm_return_url %>
  <% service.encrypted_data %>
  <%= submit_tag 'Buy!' %>
<% end %>
```

## Troublechooting
If you get a error "undefined method \`payment\_service\_for\`", you can add following configurations to initializers/allpay.rb.
``` ruby
require "offsite_payments/action_view_helper"
ActionView::Base.send(:include, OffsitePayments::ActionViewHelper)
```

Some allpay error due to CSRF token ("authenticity_token is not in spec"), you can add following scripts to remove them manually.

``` js
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
