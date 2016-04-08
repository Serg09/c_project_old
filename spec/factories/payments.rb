FactoryGirl.define do
  factory :payment, aliases: [:approved_payment] do
    donation
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state PaymentTransaction.APPROVED

    after(:create) do |payment, evaluator|
      payment.transactions << FactoryGirl.create(:payment_transaction, payment: payment)
    end

    factory :failed_payment do
      state 'failed'
    end

    factory :completed_payment do
      state 'completed'
    end
  end
end
