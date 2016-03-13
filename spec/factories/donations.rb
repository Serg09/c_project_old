FactoryGirl.define do
  factory :donation do
    campaign
    amount 100
    email { Faker::Internet.email }
  end
end
