require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let (:user) { FactoryGirl.create(:pending_user) }
  let (:admin) { FactoryGirl.create(:administrator) }

  context 'for an authenticated user' do
    before(:each) { sign_in user} 

    describe "get :index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :approve' do
      it 'redirects to the user root page' do
        patch :approve, id: user
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the user' do
        expect do
          patch :approve, id: user
          user.reload
        end.not_to change(user, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the user root page' do
        patch :reject, id: user
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the user' do
        expect do
          patch :reject, id: user
          user.reload
        end.not_to change(user, :status)
      end
    end
  end

  context 'for an authenticated administrator' do
    before(:each) { sign_in admin }

    describe "get :index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :approve' do
      it 'redirects to the users index page' do
        patch :approve, id: user
        expect(response).to redirect_to admin_users_path
      end

      it 'changes the status of the user to "approveed"' do
        expect do
          patch :approve, id: user
          user.reload
        end.to change(user, :status).to User.APPROVED
      end
    end

    describe 'patch :reject' do
      it 'redirects to the users index page' do
        patch :reject, id: user
        expect(response).to redirect_to admin_users_path
      end

      it 'changes the status of the user to "rejected"' do
        expect do
          patch :reject, id: user
          user.reload
        end.to change(user, :status).to User.REJECTED
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :approve' do
      it 'redirects to the home page' do
        patch :approve, id: user
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the user' do
        expect do
          patch :approve, id: user
          user.reload
        end.not_to change(user, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the home page' do
        patch :reject, id: user
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the user' do
        expect do
          patch :reject, id: user
          user.reload
        end.not_to change(user, :status)
      end
    end
  end
end
