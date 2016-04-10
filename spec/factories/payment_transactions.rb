FactoryGirl.define do
  factory :payment_transaction, aliases: [:approved_payment_transaction] do
    transient do
      authorization_id { Faker::Number.hexadecimal(17) }
    end
    payment
    intent PaymentTransaction.AUTHORIZE
    state 'approved'
    response do
      {
        state: state,
        transactions: [{
          related_resources: [{
            authorization: {id: authorization_id}
          }]}]
      }.to_json
    end

    factory :voided_payment_transaction do
      state 'voided'
    end

    factory :captured_payment_transaction do
      state 'captured'
    end
  end
end
