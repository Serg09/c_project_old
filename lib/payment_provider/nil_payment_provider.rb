module PaymentProvider
  class NilPaymentProvider
    def create_payment(attributes)
      {}.to_json
    end
  end
end
