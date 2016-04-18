require 'rails_helper'

RSpec.describe Admin::DonationsController, type: :controller do
  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :unfulfilled' do
      it 'is successful' do
        get :unfulfilled
        expect(response).to have_http_status :success
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :unfulfilled' do
      it 'redirects to the welcome page' do
        get :unfulfilled
        expect(response).to redirect_to root_path
      end
    end
  end
end
