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

    # Sample refund response
    #{
    #  "id":"9D221860Y7916343V",
    #  "amount": {
    #    "currency":"USD",
    #    "total":"12.34"
    #  },
    #  "state":"completed",
    #  "sale_id":"8WH11713Y20128235",
    #  "parent_payment":"PAY-2KC20852W9650701FK4J3RFY",
    #  "create_time":"2016-04-17T16:24:22Z",
    #  "update_time":"2016-04-17T16:24:22Z",
    #  "links": [{
    #    "href":"https://api.sandbox.paypal.com/v1/payments/refund/9D221860Y7916343V",
    #    "rel":"self",
    #    "method":"GET"
    #  },{
    #    "href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-2KC20852W9650701FK4J3RFY",
    #    "rel":"parent_payment",
    #    "method":"GET"
    #  },{
    #    "href":"https://api.sandbox.paypal.com/v1/payments/sale/8WH11713Y20128235",
    #    "rel":"sale",
    #    "method":"GET"
    #  }]
    #}

    def refund(sale_id, amount)
      sale = Sale.find(sale_id)
      sale.refund({
        amount: {
          currency: PayPalProvider.USD,
          total: "%.2f" % amount #TODO subtract an amount to cover payment provider fees?
        }
      })
    rescue => e
      Rails.logger.error "Unable to complete the refund of sale #{sale_id}. #{e.class.name}: #{e.message}"
      nil
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
