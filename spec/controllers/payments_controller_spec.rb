require 'rails_helper'

describe PaymentsController do
  let (:attributes) do
    {
      amount: 100,
      nonce: Faker::Number.hexadecimal(10)
    }
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

      it 'creates a payment record' do
        expect do
          post :create, payment: attributes, format: :json
        end.to change(Payment, :count).by(1)
      end

      it 'creates a transaction record' do
        expect do
          post :create, payment: attributes, format: :json
        end.to change(Transaction, :count).by(1)
      end
    end
  end
end
