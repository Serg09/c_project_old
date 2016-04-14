module PaymentProvider
  class PayPalProvider
    include PayPal::SDK::REST

    INTENTS = %w(sale authorize order)
    class << self
      INTENTS.each do |intent|
        define_method intent.upcase do
          intent
        end
      end
    end

    PAYMENT_METHODS = %w(credit_card)
    class << self
      PAYMENT_METHODS.each do |payment_method|
        define_method payment_method.upcase do
          payment_method
        end
      end
    end

    CURRENCIES = %w(USD)
    class << self
      CURRENCIES.each do |currency|
        define_method currency do
          currency
        end
      end
    end

    def create(attributes)
      payment = Payment.new payment_attributes(attributes)
      unless payment.create
        Rails.logger.error "Unable to complete the payment with the payment provider. #{payment.error.inspect}"
        raise StandardError.new("Unable to complete the payment with the payment provider")
      end
      Payment.find(payment.id)
    end

    def refund(sale_id, amount)
      sale = Sale.find(sale_id)
      sale.refund({
        amount: {
          currency: PayPalProvider.USD,
          total: amount
        }
      })
    end

    private

    def payment_attributes(attributes)
      {
        intent: PayPalProvider.SALE,
        payer: payer_attributes(attributes),
        transactions: transactions_attributes(attributes)
      }
    end

    def payer_attributes(attributes)
      {
        payment_method: PayPalProvider.CREDIT_CARD,
        funding_instruments: [
          {
            credit_card: {
              type: attributes[:credit_card_type],
              number: attributes[:credit_card],
              expire_month: attributes[:expiration_month],
              expire_year: attributes[:expiration_year],
              cvv2: attributes[:cvv],
              first_name: attributes[:first_name],
              last_name: attributes[:last_name],
              billing_address: {
                line1: attributes[:address_1],
                line2: attributes[:address_2],
                city: attributes[:city],
                state: attributes[:state],
                postal_code: attributes[:postal_code],
                country_code: 'US'
              }
            }
          }
        ]
      }
    end

    def transactions_attributes(attributes)
      [
        {
          amount: {
            total: attributes[:amount],
            currency: PayPalProvider.USD
          },
          description: attributes[:description]
        }
      ]
    end
  end
end
