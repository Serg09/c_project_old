FactoryGirl.define do
  factory :payment, aliases: [:approved_payment] do
    transient do
      sale_id { Faker::Number.hexadecimal(20) }
    end
    credit_card_number { Faker::Business.credit_card_number.gsub('-', '') }
    credit_card_type { Faker::Business.credit_card_type }
    cvv { Faker::Number.number(3).to_s }
    billing_address_1 { Faker::Address.street_address }
    billing_address_2 { Faker::Address.secondary_address }
    billing_city { Faker::Address.city }
    billing_state { Faker::Address.state_abbr }
    billing_postal_code { Faker::Address.postcode }
    billing_country_code 'US'
    contribution
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state 'approved'
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
                line1: evaluator.billing_address_1,
                line2: evaluator.billing_address_2,
                city: evaluator.billing_city,
                state: evaluator.billing_state,
                postal_code: evaluator.billing_postal_code,
                country_code: 'US'
              }
            }
          }]
        },
        transactions: [{
          amount: {
            total: payment.contribution.amount,
            current: 'USD'
          },
          description: 'Book contribution',
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
      state 'failed'
    end

    factory :pending_payment do
      state 'pending'
    end
  end
end
