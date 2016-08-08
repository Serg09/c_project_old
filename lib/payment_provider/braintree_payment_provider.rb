module PaymentProvider
  class BraintreePaymentProvider
    def get_token
      Braintree::ClientToken.generate
    end

    def form_view
      'braintree_payment_form'
    end

    def execute_payment(payment)
      result = Braintree::Transaction.sale amount: payment.amount,
                                           payment_method_nonce: payment.nonce,
                                           options: {
                                             submit_for_settlement: true
                                           }
      return BraintreeResult.new(result)
    rescue StandardError => e
      Rails.logger.error "Error executing payment #{payment.inspect} with Braintree: #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
      false
    end

    def refund_payment(payment)
      result = Braintree::Transaction.refund payment.external_id
      return BraintreeResult.new(result)
      true
    rescue StandardError => e
      Rails.logger.error "Error refunding payment #{payment.inspect} with Braintree: #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
      false
    end
  end

  class BraintreeResult
    def initialize(result)
      @result = result
    end

    def id
      @result.transaction.id
    end

    def success?
      @result.success?
    end

    def serialize
      @result.to_yaml
    end

    def state
      @result.transaction.status
    end

    def errors
      @result.errors.map do |error|
        {
          attribute: error.attribute,
          code: error.code,
          message: error.message
        }
      end
    end
  end
end
