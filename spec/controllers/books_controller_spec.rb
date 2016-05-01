require 'rails_helper'

RSpec.describe BooksController, type: :controller do
  let (:author) { FactoryGirl.create(:user) }
  let (:pending_book) { FactoryGirl.create(:pending_book, author: author) }
  let (:approved_book) { FactoryGirl.create(:approved_book, author: author) }
  let (:rejected_book) { FactoryGirl.create(:rejected_book, author: author) }
  let (:genre) { FactoryGirl.create(:genre) }
  let (:book_version_attributes) do
    {
      title: 'My book',
      short_description: 'This is short',
      long_description: 'This is long',
      genres: [genre.id]
    }
  end
  let (:attributes) do
    {
      author_id: 3987
    }
  end

  context 'for an authenticated user' do
    before(:each) { sign_in author }

    describe 'get :browse' do
      it 'is successful' do
        get :browse
        expect(response).to have_http_status :success
      end
    end

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
        post :create, author_id: author, book: book_version_attributes
        expect(response).to redirect_to book_path(Book.last)
      end

      it 'creates a new book record' do
        expect do
          post :create, author_id: author, book: book_version_attributes
        end.to change(Book, :count).by(1)
      end

      it 'creates a new book version record' do
        expect do
          post :create, author_id: author, book: book_version_attributes
        end.to change(BookVersion, :count).by(1)
      end

      it 'links the book version to the specified genres' do
        post :create, author_id: author, book: book_version_attributes
        book_version = BookVersion.last
        expect(book_version).to have(1).genre
      end
    end

    context 'that owns the book' do
      context 'that is pending approval' do
        describe 'get :show' do
          it 'redirects to the show page for the pending version' do
            get :show, id: pending_book
            expect(response).to redirect_to book_version_path(pending_book.pending_version)
          end
        end

        describe 'get :edit' do
          it 'redirects to the edit page for the current version' do
            get :edit, id: pending_book
            expect(response).to redirect_to edit_book_version_path(pending_book.pending_version)
          end
        end

        describe 'patch :update' do
          it 'redirects to the book page' do
            patch :update, id: pending_book, book: attributes
            expect(response).to redirect_to edit_book_version_path(pending_book.pending_version)
          end

          it 'does not update the book' do
            expect do
              patch :update, id: pending_book, book: attributes.merge(title: 'The new title')
              pending_book.reload
            end.not_to change(pending_book, :author_id)
          end
        end
      end

      context 'that is approved' do
        describe 'get :show' do
          it 'redirects to the show page for the approved version' do
            get :show, id: approved_book
            expect(response).to redirect_to book_version_path(approved_book.approved_version)
          end
        end

        describe 'get :edit' do
          it 'redirects to the create version page' do
            get :edit, id: approved_book
            expect(response).to redirect_to new_book_book_version_path(approved_book)
          end
        end

        describe 'patch :update' do
          it 'redirects to the book page' do
            patch :update, id: approved_book, book: attributes
            expect(response).to redirect_to new_book_book_version_path(approved_book)
          end

          it 'does not update the book' do
            expect do
              patch :update, id: approved_book, book: attributes.merge(title: 'The new title')
              approved_book.reload
            end.not_to change(approved_book, :author_id)
          end
        end
      end

      context 'that is rejected' do
        describe 'get :show' do
          it 'redirects to the show page for the rejected version' do
            get :show, id: rejected_book
            expect(response).to redirect_to book_version_path(rejected_book.rejected_version)
          end
        end

        describe 'get :edit' do
          it 'redirects to the create page' do
            get :edit, id: rejected_book
            expect(response).to redirect_to new_book_book_version_path(rejected_book)
          end
        end

        describe 'patch :update' do
          it 'redirects to the book page' do
            patch :update, id: rejected_book, book: attributes
            expect(response).to redirect_to new_book_book_version_path(rejected_book)
          end

          it 'does not update the book' do
            expect do
              patch :update, id: rejected_book, book: attributes
              rejected_book.reload
            end.not_to change(rejected_book, :author_id)
          end
        end
      end
    end

    context 'that does not own the book' do
      let (:other_user) { FactoryGirl.create(:approved_user) }
      before(:each) { sign_in other_user }

      context 'that is pending approval' do
        describe 'get :show' do
          it 'redirects to the home page' do
            get :show, id: pending_book
            expect(response).to redirect_to user_root_path
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: pending_book
            expect(response).to redirect_to user_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: pending_book, book: attributes
            expect(response).to redirect_to user_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: pending_book, book: attributes
              pending_book.reload
            end.not_to change(pending_book, :author_id)
          end
        end
      end

      # does not own the book
      context 'that is approved' do
        describe 'get :show' do
          it 'redirects to the show page for the approved version' do
            get :show, id: approved_book
            expect(response).to redirect_to book_version_path(approved_book.approved_version)
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: approved_book
            expect(response).to redirect_to user_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: approved_book, book: attributes
            expect(response).to redirect_to user_root_path
          end

          it 'does not update the book' do
            expect do
              patch :update, id: approved_book, book: attributes
              approved_book.reload
            end.not_to change(approved_book, :author_id)
          end
        end
      end

      # does not own the book
      context 'that is rejected' do
        describe 'get :show' do
          it 'redirects to the home page' do
            get :show, id: rejected_book
            expect(response).to redirect_to user_root_path
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: rejected_book
            expect(response).to redirect_to user_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: rejected_book, book: attributes
            expect(response).to redirect_to user_root_path
          end

          it 'does not update the book version' do
            expect do
              patch :update, id: rejected_book, book: attributes
              rejected_book.reload
            end.not_to change(rejected_book, :author_id)
          end
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get #index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "get #new" do
      it "redirects to the home page" do
        get :new, author_id: author
        expect(response).to redirect_to new_user_session_path
      end
    end

    describe "post #create" do
      it "redirects to the home page" do
        post :create, author_id: author, book: book_version_attributes
        expect(response).to redirect_to new_user_session_path
      end

      it 'does not create a book record' do
        expect do
          post :create, author_id: author, book: book_version_attributes
        end.not_to change(Book, :count)
      end
    end

    describe 'for a book that is pending approval' do
      describe "get #show" do
        it "redirects to the home page" do
          get :show, id: pending_book
          expect(response).to redirect_to root_path
        end
      end

      describe "get #edit" do
        it "redirects to the user sign in page" do
          get :edit, id: pending_book
          expect(response).to redirect_to new_user_session_path
        end
      end

      describe "patch #update" do
        it "redirects to the user sign in page" do
          patch :update, id: pending_book, book: attributes
          expect(response).to redirect_to new_user_session_path
        end

        it 'does not update the book' do
          expect do
            patch :update, id: pending_book, book: attributes
            pending_book.reload
          end.not_to change(pending_book, :author_id)
        end
      end
    end

    describe 'for a book that is approved' do
      describe "get #show" do
        it "redirects to the show page for the approved version" do
          get :show, id: approved_book
          expect(response).to redirect_to book_version_path(approved_book.approved_version)
        end
      end

      describe "get #edit" do
        it "redirects to the user sign in page" do
          get :edit, id: approved_book
          expect(response).to redirect_to new_user_session_path
        end
      end

      describe "patch #update" do
        it "redirects to the user sign in page" do
          patch :update, id: approved_book, book: attributes
          expect(response).to redirect_to new_user_session_path
        end

        it 'does not update the book' do
          expect do
            patch :update, id: approved_book, book: attributes
            approved_book.reload
          end.not_to change(approved_book, :author_id)
        end
      end
    end

    describe 'for a book that is rejected' do
      describe "get #show" do
        it "redirects to the hom epage" do
          get :show, id: rejected_book
          expect(response).to redirect_to root_path
        end
      end

      describe "get #edit" do
        it "redirects to the user sign in page" do
          get :edit, id: rejected_book
          expect(response).to redirect_to new_user_session_path
        end
      end

      describe "patch #update" do
        it "redirects to the user sign in page" do
          patch :update, id: rejected_book, book: attributes
          expect(response).to redirect_to new_user_session_path
        end

        it 'does not update the book' do
          expect do
            patch :update, id: rejected_book, book: attributes
            rejected_book.reload
          end.not_to change(rejected_book, :author_id)
        end
      end
    end
  end
end
