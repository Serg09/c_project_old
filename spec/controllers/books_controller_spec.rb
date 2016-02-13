require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let (:author) { FactoryGirl.create(:author) }
  let (:book_attributes) { {} }

  context 'for an authenticated author' do
    describe 'get :index' do
      it 'is successful' do
        get :index, author_id: author
        expect(response).to have_http_status :success
      end
    end

    describe 'get :new' do
      it 'is successful' do
        get :new, author_id: author
        expect(response).to have_http_status :success
      end
    end

    describe 'post :create' do
      it 'redirects to the book page' do
        post :create, author_id: author, book: book_attributes
        expect(response).to redirect_to author_books_page(author)
      end

      it 'creates a new book record' do
        expect do
          post :create, author_id: author, book: book_attributes
        end.to change(Book, :count).by(1)
      end
    end

    context 'that owns the book' do
      describe 'get :show' do
        it 'is successful'
      end

      describe 'get :edit' do
        it 'is successful'
      end

      describe 'patch :update' do
        it 'redirects to the book page'
        it 'updates the book'
      end
    end

    context 'that does not own the book' do
      context 'that is pending approval' do
        describe 'get :show' do
          it 'redirects to the home page'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the book'
        end
      end

      context 'that is approved' do
        describe 'get :show' do
          it 'is successful'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the book'
        end
      end

      context 'that is rejected' do
        describe 'get :show' do
          it 'redirects to the home page'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the book'
        end
      end
    end
  end

  context 'for an authenticated administrator' do
    describe 'get :index' do
      it 'is successful'
    end

    describe 'get :new' do
      it 'redirects to the home page'
    end

    describe 'post :create' do
      it 'redirects to the home page'
      it 'does not create a book record'
    end

    describe 'get :show' do
      context 'for book pending approval' do
        describe 'get :show' do
          it 'is successful'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the book'
        end
      end

      context 'for a book that is approved' do
        describe 'get :show' do
          it 'is successful'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the book'
        end
      end

      context 'for a book that is rejected' do
        describe 'get :show' do
          it 'is successful'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the book'
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get #index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "get #show" do
      it "is successful" do
        get :show
        expect(response).to have_http_status(:success)
      end
    end

    describe "get #new" do
      it "redirects to the author sign in page" do
        get :new
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "post #create" do
      it "redirects to the author sign in page" do
        post :create
        expect(response).to redirect_to new_author_session_path
      end
      it 'does not create a book record'
    end

    describe "get #edit" do
      it "redirects to the author sign in page" do
        get :edit
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "patch #update" do
      it "redirects to the author sign in page" do
        patch :update
        expect(response).to redirect_to new_author_session_path
      end
      it 'does not update the book record'
    end
  end
end
