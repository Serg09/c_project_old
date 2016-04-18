namespace :paypal do
  desc 'creates a payment and writes the result to the console'
  task create_payment: :environment do
    payment = PayPalTest.new.new_payment
    payment.create
    puts payment.to_json
  end

  desc 'shows a payment (required: ID)'
  task show_payment: :environment do
    payment = PayPalTest.new.find_payment(ENV['ID'])
    puts payment.to_json
  end

  desc 'refunds the specified payment (required: ID)'
  task refund_payment: :environment do
    sale = PayPalTest.new.find_sale(ENV['ID'])

    puts "before=#{sale.to_json}"
    refund = sale.refund(
      amount: {
        currency: 'USD',
        total: '12.34'
      }
    )

    puts "refund=#{refund.to_json}"
    puts "after=#{sale.to_json}"
  end
end

class PayPalTest
  include PayPal::SDK::REST

  def find_payment(id)
    Payment.find(id)
  end

  def new_payment
    transaction = {
      amount: {
        total: '12.34',
        currency: 'USD'
      },
      description: 'rake test sale'
    }
    credit_card = {
      type: 'visa',
      number: '4444111144441111',
      expire_month: '12',
      expire_year: Date.today.year + 5,
      cvv2: '123',
      first_name: 'John',
      last_name: 'Doe',
      billing_address: {
        line1: '1234 Main St',
        line2: 'Apt 227',
        city: 'Dallas',
        state: 'TX',
        postal_code: '75200',
        country_code: 'US'
      }
    }
    payer = {
      payment_method: 'credit_card',
      funding_instruments: [{
        credit_card: credit_card
      }]
    }

    payment = Payment.new(
      intent: 'sale',
      payer: payer,
      transactions: [transaction]
    )
  end

  def find_sale(id)
    Sale.find(id)
  end
end
