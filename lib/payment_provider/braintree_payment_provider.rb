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
    end

    def refund_payment(payment)
      transaction = Braintree::Transaction.find payment.external_id
      if %(settled settling).include? transaction.status
        result = Braintree::Transaction.refund payment.external_id
      else
        result = Braintree::Transaction.void payment.external_id
      end
      return BraintreeResult.new(result)
    rescue StandardError => e
      Rails.logger.error "Error refunding payment #{payment.inspect} with Braintree: #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end

    def completed?(payment)
      transaction = Braintree::Transaction.find payment.external_id
      payment.transactions.create! intent: :update,
                                   state: transaction.status,
                                   response: transaction.to_yaml
      transaction.status == 'settled'
    rescue StandardError => e
      Rails.logger.error "Error getting update for payment #{payment.inspect} with Braintree: #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
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
