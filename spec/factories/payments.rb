FactoryGirl.define do
  factory :payment, aliases: [:approved_payment] do
    transient do
      sale_id Faker::Number.hexadecimal(20)
    end
    donation
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state PaymentTransaction.APPROVED
    after(:create) do |payment, evaluator|
      transaction = {
        id: payment.external_id,
        state: payment.state,
        intent: 'sale',
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
