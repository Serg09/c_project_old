FactoryGirl.define do
  factory :payment, aliases: [:completed_payment] do
    donation
    external_id { "PAY-#{Faker::Number.hexadecimal(24)}" }
    state PaymentTransaction.COMPLETED
    after(:create) do |payment|
      FactoryGirl.create(:payment_transaction, payment: payment)
    end

    factory :failed_payment do
      state PaymentTransaction.FAILED
    end

    factory :pending_payment do
      state PaymentTransaction.PENDING
    end
  end
end
