PAYMENT_PROVIDER = Rails.env.test? ? PaymentProvider::NilPaymentProvider.new
                                   : PaymentProvider::PayPalProvider.new
