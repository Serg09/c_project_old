FactoryGirl.define do
  factory :payment, aliases: [:approved_payment] do
    donation
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state "approved"
    content { {id: external_id}.to_json }

    factory :failed_payment do
      state 'failed'
    end

    factory :completed_payment do
      state 'completed'
    end
  end
end
