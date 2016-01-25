FactoryGirl.define do
  factory :bio do
    author
    text { Faker::Lorem.paragraph(1) }
  end
end
