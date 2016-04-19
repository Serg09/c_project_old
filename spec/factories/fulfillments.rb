FactoryGirl.define do
  factory :fulfillment do
    donation
    reward
    email { Faker::Internet.email }
    address1  { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    postal_code { Faker::Address.postcode }
    country_code 'US'
    delivered false
  end
end
