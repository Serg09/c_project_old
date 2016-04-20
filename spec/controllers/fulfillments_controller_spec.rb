require 'rails_helper'

RSpec.describe FulfillmentsController, type: :controller do

  context 'for an authenticated author' do
    let (:author) { FactoryGirl.create(:approved_author) }
    before(:each){ sign_in author }

    describe "get :index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the author sign in page" do
        get :index
        expect(response).to redirect_to new_author_session_path
      end
    end
  end
end
