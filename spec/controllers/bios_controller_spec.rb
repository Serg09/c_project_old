require 'rails_helper'

RSpec.describe BiosController, type: :controller do
  include Devise::TestHelpers

  let (:author) { FactoryGirl.create(:user) }
  let (:bio) { FactoryGirl.create(:bio, author: author) }
  let (:approved_bio) { FactoryGirl.create(:approved_bio, author: author) }
  let (:attributes) do
    {
      text: 'This is some stuff about me',
      links_attributes: [
        { 'site' => 'facebook', 'url' => 'http://www.facebook.com/some_dude' },
        { 'site' => 'twitter',   'url' => 'http://www.twitter.com/some_dude' }
      ]
    }
  end

  context 'for an authenticated user' do
    before(:each) { sign_in author}

    context 'with an approved bio' do
      let!(:bio) { FactoryGirl.create(:approved_bio, author: author) }

      describe 'get :index' do
        it 'is successful' do
          get :index
          expect(response).to have_http_status :success
        end
      end
    end

    context 'with a pending bio' do
      let!(:bio) { FactoryGirl.create(:pending_bio, author: author) }

      describe 'get :index' do
        it 'is successful' do
          get :index
          expect(response).to have_http_status :success
        end
      end
    end

    context 'with a rejected bio' do
      let!(:bio) { FactoryGirl.create(:rejected_bio, author: author) }

      describe 'get :index' do
        it 'redirects to the new bio path' do
          get :index
          expect(response).to redirect_to new_bio_path
        end
      end
    end

    context 'with no bio' do
      describe 'get :index' do
        it 'redirects to the new bio path' do
          get :index
          expect(response).to redirect_to new_bio_path
        end
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
            expect(response).to redirect_to bio_path(Bio.last)
          end

          it 'does not update the bio' do
            expect do
              put :update, id: approved_bio, bio: attributes
              approved_bio.reload
            end.not_to change(approved_bio, :text)
          end

          it 'creates a new bio with the specified attributes' do
            approved_bio # create the bio before starting the expectation
            expect do
              put :update, id: approved_bio, bio: attributes
            end.to change(author.bios, :count).by(1)
          end
        end
      end

    end
    context 'that does not own the bio' do
      let (:other_user) { FactoryGirl.create(:user) }
      before(:each) { sign_in other_user }

      describe "get :show" do
        it 'is successful' do
          get :show, id: approved_bio
          expect(response).to have_http_status :success
        end
      end

      describe "get :edit" do
        it 'redirects to the user home page' do
          get :edit, id: bio
          expect(response).to redirect_to user_root_path
        end
      end

      describe 'put :update' do
        it 'redirects to the user home page' do
          put :update, id: bio, bio: attributes
          expect(response).to redirect_to user_root_path
        end

        it 'does not update the bio' do
          expect do
            put :update, id: bio, bio: attributes
            bio.reload
          end.not_to change(bio, :text)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    context 'and an author with an active bio' do
      let!(:bio) { FactoryGirl.create(:approved_bio, author: author) }

      describe 'get :index' do
        it 'is successful' do
          get :index, author_id: author
          expect(response).to have_http_status :success
        end
      end
    end

    context 'and an author without an active bio' do
      let!(:bio) { FactoryGirl.create(:pending_bio, author: author) }

      describe 'get :index' do
        it 'raises "resource not found"' do
          expect do
            get :index, author_id: author
          end.to raise_exception ActionController::RoutingError
        end
      end
    end

    describe 'get :new' do
      it 'redirects to the sign in page' do
        get :new, author_id: author
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe 'post :create' do
      it 'redirects to the sign in page' do
        post :create, author_id: author, bio: attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a new bio' do
        expect do
          post :create, author_id: author, bio: attributes
        end.not_to change(Bio, :count)
      end
    end

    context 'for an approved bio' do
      describe "get :show" do
        it 'is successful' do
          get :show, id: approved_bio
          expect(response).to have_http_status :success
        end
      end
    end

    context 'for an unapproved bio' do
      describe 'get :show' do
        it 'redirects to the welcome page' do
          # TODO will this give the proper behavior in production?
          expect do
            get :show, id: bio
          end.to raise_exception ActionController::RoutingError
        end
      end
    end

    describe "get :edit" do
      it 'redirects to the sign in page' do
        get :edit, id: bio
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
