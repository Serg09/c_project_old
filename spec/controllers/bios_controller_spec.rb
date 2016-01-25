require 'rails_helper'

RSpec.describe BiosController, type: :controller do
  include Devise::TestHelpers

  let (:author) { FactoryGirl.create(:author, status: Author.ACCEPTED) }
  let (:attributes) do
    {

    }
  end

  context 'for an authenticated author' do
    context 'that owns the bio' do
      before(:each) { sign_in author}

      describe 'get :index' do
        it 'is successful' do
          get :index
          expect(response).to have_http_status :success
        end
      end
      describe 'get :new' do
        it 'is successful' do
          get :new
          expect(response).to have_http_status :success
        end
      end
      describe 'post :create' do
        it 'redirects to the bio page' do
        end

        it 'create a new bio record'
      end
      describe "get :show" do
        it 'is successful'
      end
      describe "get :edit" do
        it 'is successful'
      end
      context 'for an approved bio' do
        describe 'put :update' do
          it 'redirects to the show bio page'
          it 'does not update the bio'
        end
        describe 'patch :approve' do
          it 'redirects to the author home page'
          it 'does not update the bio'
        end
        describe 'patch :reject' do
          it 'redirects to the author home page'
          it 'does not update the bio'
        end
      end
      context 'for an unapproved bio' do
        describe 'put :update' do
          it 'redirects to the show bio page'
          it 'updates the bio'
        end
      end
    end
    context 'that does not own the bio' do
      describe 'get :index' do
        it 'redirects to the author home page'
      end
      describe "get :show" do
        it 'redirects to the author home page'
      end
      describe "get :edit" do
        it 'redirects to the author home page'
      end
      describe 'put :update' do
        it 'redirects to the author home page'
        it 'does not update the bio'
      end
    end
  end

  context 'for an authenticated administrator' do
    describe 'get :index' do
      it 'is successful'
    end
    describe 'get :new' do
      it 'redirects to the administrator home page'
    end
    describe 'post :create' do
      it 'redirects to the administrator home page'
      it 'does not create a new bio'
    end
    describe "get :show" do
      it 'is successful'
    end
    describe "get :edit" do
      it 'redirects to the administrator home page'
    end
    context 'and an unapproved bio' do
      describe 'put :update' do
        it 'redirects to the administrator home page'
        it 'does not update the bio'
      end
      describe 'patch :approve' do
        it 'redirects to the bio index page'
        it 'updates the bio'
      end
      describe 'patch :reject' do
        it 'redirects to the bio index page'
        it 'updates the bio'
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'renders the most recently approved bio for the author'
    end
    describe 'get :new' do
      it 'redirects to the sign in page'
    end
    describe 'post :create' do
      it 'redirects to the sign in page'
      it 'does not create a new bio'
    end
    describe "get :show" do
      it 'is successful'
    end
    describe "get :edit" do
      it 'redirects to the sign in page'
    end
    context 'and an unapproved bio' do
      describe 'patch :approve' do
        it 'redirects the sign in page'
        it 'does not update the bio'
      end
      describe 'patch :reject' do
        it 'redirects to the sign in page'
        it 'does not update the bio'
      end
    end
  end
end
