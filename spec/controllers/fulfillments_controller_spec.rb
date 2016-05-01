require 'rails_helper'

RSpec.describe FulfillmentsController, type: :controller do
  let (:fulfillment) { FactoryGirl.create(:electronic_fulfillment) }
  let (:author) { fulfillment.reward.campaign.book.author }

  context 'for an authenticated user' do
    before(:each){ sign_in author }

    describe "get :index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context 'that owns the fulfillment' do
      describe 'patch :fulfill' do
        it 'redirects to the index page' do
          patch :fulfill, id: fulfillment
          expect(response).to redirect_to fulfillments_path
        end

        it 'updates the fulfillment' do
          expect do
            patch :fulfill, id: fulfillment
            fulfillment.reload
          end.to change(fulfillment, :delivered).from(false).to(true)
        end
      end
    end
  end

  context 'for an user that does not own the fulfillment' do
    let (:other_user) { FactoryGirl.create(:approved_user) }
    before(:each) { sign_in other_user }

    describe 'patch :fulfill' do
      it 'redirects to the user home page' do
        patch :fulfill, id: fulfillment
        expect(response).to redirect_to user_root_path
      end

      it 'does not update the fulfillment' do
        expect do
          patch :fulfill, id: fulfillment
          fulfillment.reload
        end.not_to change(fulfillment, :delivered)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the user sign in page" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'patch :fulfill' do
      it 'redirects to the user sign in page' do
        patch :fulfill, id: fulfillment
        expect(response).to redirect_to new_user_session_path
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
