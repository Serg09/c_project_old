require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let (:author) { FactoryGirl.create(:author) }
  let (:pending_book) { FactoryGirl.create(:pending_book, author: author) }
  let (:approved_book) { FactoryGirl.create(:approved_book, author: author) }
  let (:rejected_book) { FactoryGirl.create(:rejected_book, author: author) }
  let (:book_attributes) { FactoryGirl.attributes_for(:book, author: author) }

  context 'for an authenticated author' do
    before(:each) { sign_in author }

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
      let!(:genre1) { FactoryGirl.create(:genre) }
      let!(:genre2) { FactoryGirl.create(:genre) }

      it 'redirects to the book page' do
        post :create, author_id: author, book: book_attributes
        expect(response).to redirect_to book_path(Book.last)
      end

      it 'creates a new book record' do
        expect do
          post :create, author_id: author, book: book_attributes
        end.to change(Book, :count).by(1)
      end

      it 'links the book to the specified genres' do
        post :create, author_id: author, book: book_attributes, genres: [1]
        book = Book.last
        expect(book).to have(1).genre
      end
    end

    context 'that owns the book' do
      context 'that is pending approval' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: pending_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'is successful' do
            get :edit, id: pending_book
            expect(response).to have_http_status :success
          end
        end

        describe 'patch :update' do
          it 'redirects to the book page' do
            patch :update, id: pending_book, book: book_attributes
            expect(response).to redirect_to book_path(pending_book)
          end

          it 'updates the book' do
            expect do
              patch :update, id: pending_book, book: book_attributes.merge(title: 'The new title')
              pending_book.reload
            end.to change(pending_book, :title).to('The new title')
          end
        end
      end

      context 'that is approved' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: approved_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: approved_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: approved_book, book: book_attributes
            expect(response).to redirect_to author_root_path
          end

          it 'updates the book' do
            expect do
              patch :update, id: approved_book, book: book_attributes.merge(title: 'The new title')
              approved_book.reload
            end.not_to change(approved_book, :title)
          end
        end
      end
      context 'that is rejected' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: rejected_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: rejected_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: rejected_book, book: book_attributes
            expect(response).to redirect_to author_root_path
          end

          it 'updates the book' do
            expect do
              patch :update, id: rejected_book, book: book_attributes.merge(title: 'New title')
              rejected_book.reload
            end.not_to change(rejected_book, :title)
          end
        end
      end
    end

    context 'that does not own the book' do
      let (:other_author) { FactoryGirl.create(:approved_author) }
      before(:each) { sign_in other_author }

      context 'that is pending approval' do
        describe 'get :show' do
          it 'redirects to the home page' do
            get :show, id: pending_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: pending_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: pending_book, book: book_attributes
            expect(response).to redirect_to author_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: pending_book, book: book_attributes.merge(title: 'The new title')
              pending_book.reload
            end.not_to change(pending_book, :title)
          end
        end
      end

      # does not own the book
      context 'that is approved' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: approved_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: approved_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: approved_book, book: book_attributes
            expect(response).to redirect_to author_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: approved_book, book: book_attributes.merge(title: 'New title')
              approved_book.reload
            end.not_to change(approved_book, :title)
          end
        end
      end

      # does not own the book
      context 'that is rejected' do
        describe 'get :show' do
          it 'redirects to the home page' do
            get :show, id: rejected_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: rejected_book
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: rejected_book, book: book_attributes
            expect(response).to redirect_to author_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: rejected_book, book: book_attributes.merge(title: 'New title')
              rejected_book.reload
            end.not_to change(rejected_book, :title)
          end
        end
      end
    end
  end

  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success

        get :index, author: author
        expect(response).to have_http_status :success
      end
    end

    describe 'get :new' do
      it 'redirects to the home page' do
        get :new, author_id: author
        expect(response).to redirect_to admin_root_path
      end
    end

    describe 'post :create' do
      it 'redirects to the home page' do
        post :create, author_id: author, book: book_attributes
        expect(response).to redirect_to admin_root_path
      end

      it 'does not create a book record' do
        expect do
          post :create, author_id: author, book: book_attributes
        end.not_to change(Book, :count)
      end
    end

    # for an administrator
    describe 'get :show' do
      context 'for book pending approval' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: pending_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: pending_book
            expect(response).to redirect_to admin_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: pending_book, book: book_attributes
            expect(response).to redirect_to admin_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: pending_book, book: book_attributes.merge(title: 'New title')
              pending_book.reload
            end.not_to change(pending_book, :title)
          end
        end
      end

      # for an administrator
      context 'for a book that is approved' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: approved_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: approved_book
            expect(response).to redirect_to admin_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: approved_book, book: book_attributes
            expect(response).to redirect_to admin_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: approved_book, book: book_attributes.merge(title: 'New title')
              approved_book.reload
            end.not_to change(approved_book, :title)
          end
        end
      end

      # for an administrator
      context 'for a book that is rejected' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: rejected_book
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: rejected_book
            expect(response).to redirect_to admin_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: rejected_book, book: book_attributes
            expect(response).to redirect_to admin_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: rejected_book, book: book_attributes.merge(title: 'New title')
              rejected_book.reload
            end.not_to change(rejected_book, :title)
          end
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

    describe "get #new" do
      it "redirects to the home page" do
        get :new, author_id: author
        expect(response).to redirect_to root_path
      end
    end

    describe "post #create" do
      it "redirects to the home page" do
        post :create, author_id: author, book: book_attributes
        expect(response).to redirect_to root_path
      end

      it 'does not create a book record' do
        expect do
          post :create, author_id: author, book: book_attributes
        end.not_to change(Book, :count)
      end
    end

    describe 'for a book that is pending approval' do
      describe "get #show" do
        it "redirects to the sign in page" do
          get :show, id: pending_book
          expect(response).to redirect_to root_path
        end
      end

      describe "get #edit" do
        it "redirects to the home page" do
          get :edit, id: pending_book
          expect(response).to redirect_to root_path
        end
      end

      describe "patch #update" do
        it "redirects to the home page" do
          patch :update, id: pending_book, book: book_attributes
          expect(response).to redirect_to root_path
        end

        it 'does not update the book record' do
          expect do
            patch :update, id: pending_book, book: book_attributes.merge(title: 'New title')
            pending_book.reload
          end.not_to change(pending_book, :title)
        end
      end
    end

    describe 'for a book that is approved' do
      describe "get #show" do
        it "is successful" do
          get :show, id: approved_book
          expect(response).to have_http_status :success
        end
      end

      describe "get #edit" do
        it "redirects to the home page" do
          get :edit, id: approved_book
          expect(response).to redirect_to root_path
        end
      end

      describe "patch #update" do
        it "redirects to the home page" do
          patch :update, id: approved_book, book: book_attributes
          expect(response).to redirect_to root_path
        end

        it 'does not update the book record' do
          expect do
            patch :update, id: approved_book, book: book_attributes.merge(title: 'New title')
            approved_book.reload
          end.not_to change(approved_book, :title)
        end
      end
    end

    describe 'for a book that is rejected' do
      describe "get #show" do
        it "redirects to the home page" do
          get :show, id: rejected_book
          expect(response).to redirect_to root_path
        end
      end

      describe "get #edit" do
        it "redirects to the home page" do
          get :edit, id: rejected_book
          expect(response).to redirect_to root_path
        end
      end

      describe "patch #update" do
        it "redirects to the home page" do
          patch :update, id: rejected_book, book: book_attributes
          expect(response).to redirect_to root_path
        end

        it 'does not update the book record' do
          expect do
            patch :update, id: rejected_book, book: book_attributes.merge(title: 'New title')
            rejected_book.reload
          end.not_to change(rejected_book, :title)
        end
      end
    end
  end
end
