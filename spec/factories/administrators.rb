FactoryGirl.define do
  factory :administrator do
    email { Faker::Internet.email }
    password "please01"
    password_confirmation "please01"
  end
end
