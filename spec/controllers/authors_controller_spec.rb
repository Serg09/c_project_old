require 'rails_helper'

RSpec.describe AuthorsController, type: :controller do
  include Devise::TestHelpers

  let (:author) { FactoryGirl.create(:author) }

  context 'for an authenticated user' do
    context 'that is the author in question' do
      before(:each) { sign_in author }

      describe "get :show" do
        it "is successful" do
          get :show, id: author
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :edit" do
        it "returns http success" do
          get :edit, id: author
          expect(response).to have_http_status(:success)
        end
      end

      describe "patch :update" do
        it "updates the specified author" do
          expect do
            patch :update, id: author, author: { first_name: 'Jimbob' }
            author.reload
          end.to change(author, :first_name).to 'Jimbob'
        end

        it "redirects to the author profile page" do
          patch :update, id: author, author: { first_name: 'Jimbob' }
          expect(response).to redirect_to author_path(author)
        end
      end
    end

    context 'that is not the author in question' do
      let (:other_author) { FactoryGirl.create(:author) }
      before(:each) { sign_in other_author }

      describe 'get :show' do
        it 'redirects to user\'s profile page' do
          get :show, id: author
          expect(response).to redirect_to author_path(other_author)
        end
      end

      describe 'get :edit' do
        it 'redirects to user\'s profile page' do
          get :edit, id: author
          expect(response).to redirect_to author_path(other_author)
        end
      end

      describe 'patch :update' do
        it 'redirects to user\'s profile page' do
          patch :update, id: author, author: { first_name: 'Jimbob' }
          expect(response).to redirect_to author_path(other_author)
        end

        it 'does not update the specified author' do
          expect do
            patch :update, id: author, author: { first_name: 'Jimbob' }
            author.reload
          end.not_to change(author, :first_name)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :show' do
      it 'redirects to the sign in page' do
        get :show, id: author
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe 'get :edit' do
      it 'redirects to the sign in page' do
        get :edit, id: author
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe 'patch :update' do
      it 'redirects to the sign in page' do
          patch :update, id: author, author: { first_name: 'Jimbob' }
          expect(response).to redirect_to new_author_session_path
      end

      it 'does not update the specified author' do
        expect do
          patch :update, id: author, author: { first_name: 'Jimbob' }
          author.reload
        end.not_to change(author, :first_name)
      end
    end
  end
end
