require 'rails_helper'

RSpec.describe Admin::FulfillmentsController, type: :controller do
  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :fulfill' do
      let!(:fulfillment) { FactoryGirl.create(:electronic_fulfillment) }

      it 'redirects to the index page' do
        patch :fulfill, id: fulfillment
        expect(response).to redirect_to admin_fulfillments_path
      end

      it 'marks the record has fulfilled' do
        expect do
          patch :fulfill, id: fulfillment
          fulfillment.reload
        end.to change(fulfillment, :delivered).from(false).to(true)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the welcome page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :fulfill' do
      let!(:fulfillment) { FactoryGirl.create(:electronic_fulfillment) }

      it 'redirects to the welcome page' do
        patch :fulfill, id: fulfillment
        expect(response).to redirect_to root_path
      end

      it 'does not update the fulfillment' do
        expect do
          patch :fulfill, id: fulfillment
          fulfillment.reload
        end.not_to change(fulfillment, :delivered)
      end
    end
  end
end
