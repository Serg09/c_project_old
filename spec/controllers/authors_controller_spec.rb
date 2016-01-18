require 'rails_helper'

RSpec.describe AuthorsController, type: :controller do
  include Devise::TestHelpers

  let (:author) { FactoryGirl.create(:author, email: 'john@doe.com') }

  context 'for an authenticated author' do

    describe "get :index" do
      it "redirects to the author root path" do
        sign_in author
        get :index
        expect(response).to redirect_to author_root_path
      end
    end

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

      describe 'patch :accept' do
        it 'redirects to the author root page' do
          patch :accept, id: author
          expect(response).to redirect_to author_root_path
        end

        it 'does not change the status of the author' do
          expect do
            patch :accept, id: author
            author.reload
          end.not_to change(author, :status)
        end
      end

      describe 'patch :reject' do
        it 'redirects to the author root page' do
          patch :reject, id: author
          expect(response).to redirect_to author_root_path
        end

        it 'does not change the status of the author' do
          expect do
            patch :reject, id: author
            author.reload
          end.not_to change(author, :status)
        end
      end
    end

    context 'that is not the author in question' do
      let (:other_author) { FactoryGirl.create(:author) }
      before(:each) { sign_in other_author }

      describe 'get :show' do
        it 'redirects to author\'s profile page' do
          get :show, id: author
          expect(response).to redirect_to author_root_path
        end
      end

      describe 'get :edit' do
        it 'redirects to author\'s profile page' do
          get :edit, id: author
          expect(response).to redirect_to author_root_path
        end
      end

      describe 'patch :update' do
        it 'redirects to author\'s profile page' do
          patch :update, id: author, author: { first_name: 'Jimbob' }
          expect(response).to redirect_to author_root_path
        end

        it 'does not update the specified author' do
          expect do
            patch :update, id: author, author: { first_name: 'Jimbob' }
            author.reload
          end.not_to change(author, :first_name)
        end
      end

      describe 'patch :accept' do
        it 'redirects to the author root page' do
          patch :accept, id: author
          expect(response).to redirect_to author_root_path
        end

        it 'does not change the status of the author' do
          expect do
            patch :accept, id: author
            author.reload
          end.not_to change(author, :status)
        end
      end

      describe 'patch :reject' do
        it 'redirects to the author root page' do
          patch :reject, id: author
          expect(response).to redirect_to author_root_path
        end

        it 'does not change the status of the author' do
          expect do
            patch :reject, id: author
            author.reload
          end.not_to change(author, :status)
        end
      end
    end
  end

  context 'for an administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe "get :index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "get :show" do
      it "is successful" do
        get :show, id: author
        expect(response).to have_http_status(:success)
      end
    end

    describe 'patch :accept' do
      it 'redirects to the authors index page' do
        patch :accept, id: author
        expect(response).to redirect_to authors_path
      end

      it 'changes the status of the author to "accepted"' do
        expect do
          patch :accept, id: author
          author.reload
        end.to change(author, :status).to Author.accepted
      end
    end

    describe 'patch :reject' do
      it 'redirects to the authors index page' do
        patch :reject, id: author
        expect(response).to redirect_to authors_path
      end

      it 'changes the status of the author to "rejected"' do
        expect do
          patch :reject, id: author
          author.reload
        end.to change(author, :status).to Author.rejected
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

    describe 'patch :accept' do
      it 'redirects to the sign in page' do
        patch :accept, id: author
        expect(response).to redirect_to new_author_session_path
      end

      it 'does not change the status of the author' do
        expect do
          patch :accept, id: author
          author.reload
        end.not_to change(author, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the sign in page' do
        patch :reject, id: author
        expect(response).to redirect_to new_author_session_path
      end

      it 'does not change the status of the author' do
        expect do
          patch :reject, id: author
          author.reload
        end.not_to change(author, :status)
      end
    end
  end
end
