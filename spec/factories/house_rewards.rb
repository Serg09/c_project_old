FactoryGirl.define do
  factory :house_reward do
    description { Faker::Hipster.sentence(4, 3) }
    physical_address_required false
  end
end
