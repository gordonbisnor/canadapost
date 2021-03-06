# Canadapost

A gem to facilitate Ruby on Rails interaction with Canada Post's REST API. 

This is currently the most basic implementation that I needed for a particular project, and only has provisions for obtaining a list of shipping rates. I invite you to extend or improve as you see fit.

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'canadapost'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install canadapost
```

## Usage

``` ruby
canada_post = Canadapost.new({
    username: "xxx", 
 	password: "xxx",
	customer_number: 'xxx',
 	development: true (optional) 
 	})

canada_post.origin_postal_code = "xxx"
canada_post.dimensions = {}
canada_post.customer = {}
canada_post.get_rates
```

get_rates returns a hash of services, including:

- :service_name
- :service_code
- :price_details, with [:due] as the total amount
- :service_link, with [:href] as the URL
- :service_standard, with [:expected_transit_time] as the estimated number of days for delivery (from today)

**dimension hash**
{weight: x.x, height: x.x, length: x.x, width: x.x } 
Weight is kilograms; height, length, width are centimetres

**customer hash:**
for us: { :'united-states' => { :'zip-code' => 'xxxxx' } }
for canada: { domestic: { :'postal-code' => 'xxxxxx' } }
for international: { international: { :'country-code' => 'xx' } }

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
