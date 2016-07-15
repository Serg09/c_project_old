module PaymentProvider
  class PayPalProvider
    include PayPal::SDK::REST
    include ActiveSupport::NumberHelper

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

    def execute_payment(internal_payment)
      payment = Payment.new payment_attributes(internal_payment)
      unless payment.create
        Rails.logger.error "Unable to complete the payment with the payment provider. #{payment.error.inspect}"
        raise StandardError.new("Unable to complete the payment with the payment provider")
      end
      internal_payment.provider_fee = calculate_fee(internal_payment)
      PayPalPaymentResponse.new(Payment.find(payment.id))
    end

    def refund_payment(payment)
      sale = Sale.find(payment.sale_id)
      sale.refund({
        amount: {
          currency: PayPalProvider.USD,
          total: "%.2f" % payment.amount
        }
      })
    rescue => e
      Rails.logger.error "Unable to complete the refund of sale #{sale_id}. #{e.class.name}: #{e.message}"
      nil
    end

    private

    FEE_RATE = 0.029
    FLAT_FEE = 0.30
    def calculate_fee(payment)
      payment.amount * FEE_RATE + FLAT_FEE
    end

    def payment_attributes(internal_payment)
      {
        intent: PayPalProvider.SALE,
        payer: payer_attributes(internal_payment),
        transactions: transactions_attributes(internal_payment)
      }
    end

    def payer_attributes(internal_payment)
      {
        payment_method: PayPalProvider.CREDIT_CARD,
        funding_instruments: [
          {
            credit_card: {
              type: internal_payment.credit_card_type,
              number: internal_payment.credit_card_number,
              expire_month: internal_payment.expiration_month,
              expire_year: internal_payment.expiration_year,
              cvv2: internal_payment.cvv,
              first_name: internal_payment.first_name,
              last_name: internal_payment.last_name,
              billing_address: {
                line1: internal_payment.billing_address_1,
                line2: internal_payment.billing_address_2,
                city: internal_payment.billing_city,
                state: internal_payment.billing_state,
                postal_code: internal_payment.billing_postal_code,
                country_code: 'US'
              }
            }
          }
        ]
      }
    end

    def transactions_attributes(internal_payment)
      book = internal_payment.contribution.campaign.book
      description = "#{number_to_currency(internal_payment.amount, precision: 2)} contribution to the book \"#{book.public_title}\" by #{book.author.full_name}"
      [
        {
          amount: {
            total: '%.2f' % internal_payment.amount,
            currency: PayPalProvider.USD
          },
          description: description
        }
      ]
    end
  end
end
