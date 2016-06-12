require 'rails_helper'

describe InquiriesController do
  include Devise::TestHelpers
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@doe.com',
      body: 'Does anyone know what time it is?'
    }
  end

  context 'for an unauthenticated user' do
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

      it 'redirects to the confirmation (show) page' do
        post :create, inquiry: attributes
        expect(response).to redirect_to inquiry_path(Inquiry.last)
      end

      it 'sends a notification email' do
        mail = spy('mail')
        expect(AdminMailer).to receive(:inquiry_received).and_return(mail)
        post :create, inquiry: attributes
        expect(mail).to have_received(:deliver_now)
      end
    end
  end

  context 'for an authenticated user' do
    let (:user) { FactoryGirl.create(:user) }
    before(:each) { sign_in user }

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
        expect(response).to redirect_to inquiry_path(Inquiry.last)
      end

      it 'sends a notification email' do
        mail = spy('mail')
        expect(AdminMailer).to receive(:inquiry_received).and_return(mail)
        post :create, inquiry: attributes
        expect(mail).to have_received(:deliver_now)
      end
    end
  end
end


