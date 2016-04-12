FactoryGirl.define do
  factory :payment do
    donation
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state PaymentTransaction.COMPLETED

    factory :approved_payment do
      transient do
        authorization_id { Faker::Number.hexadecimal(17) }
      end
      after(:create) do |payment, evaluator|
        transaction = FactoryGirl.create(:payment_transaction,
                                         payment: payment,
                                         authorization_id: evaluator.authorization_id)
        payment.transactions << transaction
      end

      factory :failed_payment do
        state 'failed'
      end

      factory :completed_payment do
        state 'completed'
      end
    end
  end
end
