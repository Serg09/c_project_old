module PaymentProvider
  class NilPaymentProvider
    def execute_payment(payment)
      return_from_file('payment_create_approved.json')
    end

    def refund_payment(payment)
      return_from_file('payment_refund_completed.json')
    end

    private

    def return_from_file(file_name)
      path = Rails.root.join('spec', 'fixtures', 'files', file_name)
      raw = File.read(path)
      json = JSON.parse(raw, symbolize_names: true)
      json[:id] = "PAY-#{Faker::Number.hexadecimal(10)}"
      OpenStruct.new(id: json[:id],
                     state: json[:state],
                     success?: %(approved completed).include?(json[:state]),
                     serialize: json.to_json)
    end
  end
end
