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

      Rails.logger.debug "Braintree result: #{result.inspect}"
      Rails.logger.debug "Braintree result in JSON: #{result.to_json}"
      true
    rescue StandardError => e
      Rails.logger.error "Error executing payment #{payment.inspect} with Braintree: #{e.class.name} - #{e.message}\n  #{e.backtrace.join("\n  ")}"
      false
    end
  end
end
