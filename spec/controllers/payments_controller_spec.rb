require 'rails_helper'

describe PaymentsController do
  let (:attributes) do
    {
      amount: 100,
      nonce: Faker::Number.hexadecimal(10)
    }
  end

  describe 'get :token' do
    context 'in json' do
      it 'is successful' do
        get :token
        expect(response).to have_http_status :success
      end

      it 'returns a token' do
        get :token
        # the test payment provider returns a 10-digit hexadecimal number
        expect(response.body).to match /[a-f0-9]{10}/i
      end
    end
  end

  describe 'post :create' do
    context 'in json' do
      it 'is successful' do
        post :create, payment: attributes, format: :json
        expect(response).to have_http_status :success
      end

      it 'returns the payment' do
        post :create, payment: attributes, format: :json
        payment = JSON.parse(response.body, symbolize_names: true)
        expect(payment).to include :id
        expect(payment).to include amount: '100.0'
      end

      it 'executes the payment through the payment provider' do
        expect(PAYMENT_PROVIDER).to receive(:execute_payment)
          .with(Payment)
        post :create, payment: attributes, format: :json
      end
    end
  end
end
