FactoryGirl.define do
  factory :payment_transaction, aliases: [:approved_payment_transaction] do
    payment
    intent PaymentTransaction.SALE
    state 'completed'
    response do
      {
        id: Faker::Number.hexadecimal(20),
        state: state,
        intent: 'sale',
        payer: {
          payment_method: 'credit_card',
          funding_instruments: [{
            credit_card: {
              type: 'visa',
              number: 'xxxxxxxxxxxx1111',
              expire_month: '12',
              expire_year: '2020',
              first_name: 'John',
              last_name: 'Doe',
              billing_address: {
                line1: '1234 Main St',
                line2: 'Apt 227',
                city: 'Dallas',
                state: 'TX',
                postal_code: '75200',
                country_code: 'US'
              }
            }
          }]
        }
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
