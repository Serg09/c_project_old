FactoryGirl.define do
  factory :house_reward, aliases: [:electronic_house_reward] do
    description { Faker::Hipster.sentence(4, 3) }
    physical_address_required false

    factory :physical_house_reward do
      physical_address_required true
    end
  end
end
