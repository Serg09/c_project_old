require 'rails_helper'

describe Admin::InquiriesController do

  let (:inquiry) { FactoryGirl.create(:inquiry) }

  context 'for an administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe 'get :show' do
      it 'is successful' do
        get :show, id: inquiry
        expect(response).to have_http_status(:success)
      end
    end

    describe 'patch :archive' do
      it 'redirects to the inquiry index page' do
        patch :archive, id: inquiry
        expect(response).to redirect_to admin_inquiries_path
      end

      it 'updates the inquiry' do
        expect do
          patch :archive, id: inquiry
          inquiry.reload
        end.to change(inquiry, :archived).from(false).to(true)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the root page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'get :show' do
      it 'redirects to the root page' do
        get :show, id: inquiry
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :archive' do
      it 'redirects to the root page' do
        patch :archive, id: inquiry
        expect(response).to redirect_to root_path
      end

      it 'does not update the inquiry' do
        expect do
          patch :archive, id: inquiry
          inquiry.reload
        end.not_to change(inquiry, :archived)
      end
    end
  end
end
