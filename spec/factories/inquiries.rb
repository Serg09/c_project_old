FactoryGirl.define do
  factory :inquiry do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email(first_name) }
    body { Faker::Lorem.sentence(3) }
    archived false
  end
end
