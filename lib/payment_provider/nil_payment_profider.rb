class NilPaymentProvider
  def create_payment
    return {}.to_json
  end
end
