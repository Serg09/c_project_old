FactoryGirl.define do
  factory :payment_transaction, aliases: [:completed_payment_transaction] do
    payment
    intent PaymentTransaction.SALE
    state 'completed'
    response do
      {
        id: Faker::Number.hexadecimal(20),
        state: state,
      }.to_json
    end

    factory :pending_payment_transaction do
      state 'pending'
    end

    factory :failed_payment_transaction do
      state 'failed'
    end
  end
end
