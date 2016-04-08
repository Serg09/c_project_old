FactoryGirl.define do
  factory :payment_transaction do
    payment
    intent PaymentTransaction.AUTHORIZE
    state PaymentTransaction.APPROVED
    response { {state: 'approved'}.to_json }
  end
end
