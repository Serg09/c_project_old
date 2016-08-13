class PaymentsController < ApplicationController
  respond_to :json

  def token
    render json: { token: PAYMENT_PROVIDER.get_token }
  end

  def create
    @payment = Payment.new payment_params
    @payment.save!
    @payment.execute!

    respond_with @payment, location: '/'
  end

  private

  def payment_params
    params.require(:payment).
      permit(:amount, :nonce).
      merge(state: :pending)
  end
end
