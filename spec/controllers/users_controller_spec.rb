require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::TestHelpers

  let (:user) { FactoryGirl.create(:user, email: 'john@doe.com') }

  context 'for an authenticated user' do

    describe "get :index" do
      it "redirects to the user root path" do
        sign_in user
        get :index
        expect(response).to redirect_to user_path(user)
      end
    end

    context 'that is the user in question' do
      before(:each) { sign_in user }

      describe "get :show" do
        it "is successful" do
          get :show, id: user
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :edit" do
        it "returns http success" do
          get :edit, id: user
          expect(response).to have_http_status(:success)
        end
      end

      describe "patch :update" do
        it "updates the specified user" do
          expect do
            patch :update, id: user, user: { first_name: 'Jimbob' }
            user.reload
          end.to change(user, :first_name).to 'Jimbob'
        end

        it "redirects to the user profile page" do
          patch :update, id: user, user: { first_name: 'Jimbob' }
          expect(response).to redirect_to user_path(user)
        end
      end
    end

    context 'that is not the user in question' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe 'get :show' do
        it 'redirects to user\'s profile page' do
          get :show, id: user
          expect(response).to redirect_to user_root_path
        end
      end

      describe 'get :edit' do
        it 'redirects to user\'s profile page' do
          get :edit, id: user
          expect(response).to redirect_to user_root_path
        end
      end

      describe 'patch :update' do
        it 'redirects to user\'s profile page' do
          patch :update, id: user, user: { first_name: 'Jimbob' }
          expect(response).to redirect_to user_root_path
        end

        it 'does not update the specified user' do
          expect do
            patch :update, id: user, user: { first_name: 'Jimbob' }
            user.reload
          end.not_to change(user, :first_name)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :show' do
      it 'redirects to the sign in page' do
        get :show, id: user
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: user
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'patch :update' do
      it 'redirects to the sign in page' do
          patch :update, id: user, user: { first_name: 'Jimbob' }
          expect(response).to redirect_to new_user_session_path
      end

      it 'does not update the specified user' do
        expect do
          patch :update, id: user, user: { first_name: 'Jimbob' }
          user.reload
        end.not_to change(user, :first_name)
      end
    end
  end
end
