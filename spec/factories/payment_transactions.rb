FactoryGirl.define do
  factory :payment_transaction, aliases: [:completed_payment_transaction] do
    transient do
      authorization_id { Faker::Number.hexadecimal(17) }
    end
    payment
    intent PaymentTransaction.SALE
    state 'completed'
    response do
      {
        state: state,
        transactions: [{
          related_resources: [{
            authorization: {id: authorization_id}
          }]}]
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
