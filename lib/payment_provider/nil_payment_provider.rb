module PaymentProvider
  class NilPaymentProvider
    def create(attributes)
      path = Rails.root.join('spec', 'fixtures', 'files', 'payment.json')
      raw = File.read(path)
      json = JSON.parse(raw, symbolize_names: true)
      OpenStruct.new(id: json[:id], state: json[:state], to_json: json)
    end
  end
end
