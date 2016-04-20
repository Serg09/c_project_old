FactoryGirl.define do
  factory :payment, aliases: [:approved_payment] do
    transient do
      sale_id { Faker::Number.hexadecimal(20) }
      address_1 { Faker::Address.street_address }
      address_2 { Faker::Address.secondary_address }
      city { Faker::Address.city }
      state_abbr { Faker::Address.state_abbr }
      postal_code { Faker::Address.postcode }
    end
    donation
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state PaymentTransaction.APPROVED
    after(:create) do |payment, evaluator|
      transaction = {
        id: payment.external_id,
        state: payment.state,
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
                line1: evaluator.address_1,
                line2: evaluator.address_2,
                city: evaluator.city,
                state: evaluator.state,
                postal_code: evaluator.postal_code,
                country_code: 'US'
              }
            }
          }]
        },
        transactions: [{
          amount: {
            total: payment.donation.amount,
            current: 'USD'
          },
          description: 'Book donation',
          related_resources: [{
            sale: {
              id: evaluator.sale_id,
              state: 'completed'
            }
          }]
        }]
      }.to_json
      FactoryGirl.create(:payment_transaction, payment: payment, response: transaction)
    end

    factory :failed_payment do
      state PaymentTransaction.FAILED
    end

    factory :pending_payment do
      state PaymentTransaction.PENDING
    end
  end
end
