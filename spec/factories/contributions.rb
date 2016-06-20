FactoryGirl.define do
  factory :contribution, aliases: [:pledged_contribution] do
    campaign
    amount { Faker::Number.between(100, 1000) }
    email { Faker::Internet.email }
    ip_address { Faker::Internet.ip_v4_address }
    user_agent 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'
    state 'pledged'

    factory :collected_contribution do
      state 'collected'
      after(:create) do |contribution|
        FactoryGirl.create(:approved_payment, contribution: contribution)
      end
    end

    factory :cancelled_contribution do
      state 'cancelled'
    end
  end
end
