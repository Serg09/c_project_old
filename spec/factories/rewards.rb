FactoryGirl.define do
  factory :reward do
    campaign
    description { Faker::Hipster.words(5) }
    long_description { Faker::Hipster.sentences(3) }
    physical_address_required false
    minimum_contribution 10
  end
end
