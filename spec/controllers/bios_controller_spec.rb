require 'rails_helper'

RSpec.describe BiosController, type: :controller do
  include Devise::TestHelpers

  let (:author) { FactoryGirl.create(:author, status: Author.ACCEPTED) }
  let (:bio) { FactoryGirl.create(:bio, author: author) }
  let (:approved_bio) { FactoryGirl.create(:bio, author: author, status: Bio.APPROVED) }
  let (:attributes) do
    {
      text: 'This is some stuff about me',
      links: [
        {site: :facekbook, url: 'http://www.facebook.com/some_dude'},
        {site: :twitter, url: 'http://www.twitter.com/some_dude'}
      ]
    }
  end

  context 'for an authenticated author' do
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
        post :create, bio: attributes
        expect(response).to redirect_to bios_path
      end

      it 'create a new bio record' do
        expect do
          post :create, bio: attributes
          author.bios.reload
        end.to change(author.bios, :count).by(1)
      end
    end

    context 'that owns the bio' do
      describe "get :show" do
        it 'is successful' do
          get :show, id: bio
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :edit" do
        it 'is successful' do
          get :edit, id: bio
          expect(response).to have_http_status(:success)
        end
      end

      context 'for an approved bio' do
        describe 'put :update' do
          it 'redirects to the show bio page' do
            put :update, id: approved_bio, bio: attributes
            expect(response).to redirect_to bio_path(approved_bio)
          end

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
