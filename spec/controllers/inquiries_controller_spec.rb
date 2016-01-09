require 'rails_helper'

describe InquiriesController do
  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@doe.com',
      body: 'Does anyone know what time it is?'
    }
  end

  describe 'get :new' do
    it 'is successful' do
      get :new
      expect(response).to be_success
    end
  end

  describe 'post :create' do
    it 'creates a new inquiry' do
      expect do
        post :create, inquiry: attributes
      end.to change(Inquiry, :count).by(1)
    end

    it 'redirects to the books page' do
      post :create, inquiry: attributes
      expect(response).to redirect_to pages_books_path
    end
  end
end


