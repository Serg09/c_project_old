require 'rails_helper'

RSpec.describe Admin::CampaignsController, type: :controller do
  let (:admin) { FactoryGirl.create(:administrator) }
  let (:campaign) { FactoryGirl.create(:campaign) }

  context 'for an authenticated administrator' do
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'get :show' do
      it 'is successful' do
        get :show, id: campaign
        expect(response).to have_http_status :success
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the home page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'get :show' do
      it 'redirects to the home page' do
        get :show, id: campaign
        expect(response).to redirect_to root_path
      end
    end
  end
end
