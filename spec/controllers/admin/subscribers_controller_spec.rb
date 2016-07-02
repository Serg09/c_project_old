require 'rails_helper'

RSpec.describe Admin::SubscribersController, type: :controller do

  context 'for an authenticate administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end
  end
end
