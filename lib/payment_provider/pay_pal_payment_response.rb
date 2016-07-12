module PaymentProvider
  class PayPalPaymentResponse
    def initialize(payment)
      @payment = payment
    end

    def id
      @payment.id
    end

    def state
      @payment.state
    end

    def success?
      %w(created approved completed).include? @payment.state
    end

    def serialize
      @payment.to_json
    end
  end
end
