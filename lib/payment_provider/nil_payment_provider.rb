module PaymentProvider
  class NilPaymentProvider
    def create(attributes)
      path = Rails.root.join('spec', 'fixtures', 'files', 'payment.json')
      raw = File.read(path)
      JSON.parse(raw, symbolize_names: true)
    end
  end
end
