FactoryGirl.define do
  factory :reward, aliases: [:electronic_reward] do
    campaign
    description { Faker::Hipster.words(5) }
    long_description { Faker::Hipster.sentences(3) }
    physical_address_required false
    minimum_contribution 10

    factory :physical_reward do
      physical_address_required true
    end
  end
end
