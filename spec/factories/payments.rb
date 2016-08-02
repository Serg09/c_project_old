FactoryGirl.define do
  factory :payment, aliases: [:approved_payment] do
    transient do
      sale_id { Faker::Number.hexadecimal(20) }
      contribution nil
    end
    nonce { Faker::Number.hexadecimal(10) }
    amount { Faker::Number.decimal(2) }
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state 'approved'
    after(:create) do |payment, evaluator|
      payment.contributions << evaluator.contribution if evaluator.contribution
      transaction = {
        id: payment.external_id,
        state: payment.state,
        intent: 'sale',
      }.to_json
      FactoryGirl.create(:payment_transaction, payment: payment, response: transaction)
    end

    factory :completed_payment do
      state 'completed'
    end

    factory :failed_payment do
      state 'failed'
    end

    factory :pending_payment do
      state 'pending'
    end

    factory :refunded_payment do
      state 'refunded'
    end
  end
end
