require 'rails_helper'

RSpec.describe Admin::PaymentsController, type: :controller do
  let (:payment) { FactoryGirl.create(:payment) }

  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe "GET #show" do
      it "returns http success" do
        get :show, id: payment
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'GET #show' do
      it 'redirects to the home page' do
        get :show, id: payment
        expect(response).to redirect_to root_path
      end
    end
  end
end
