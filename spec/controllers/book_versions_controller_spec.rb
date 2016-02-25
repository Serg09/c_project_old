require 'rails_helper'

RSpec.describe BookVersionsController, type: :controller do
  let (:author) { FactoryGirl.create(:approved_author) }
  let (:book) { FactoryGirl.create(:approved_book, author: author) }
  let (:approved_version) { book.approved_version }
  let (:pending_version) { FactoryGirl.create(:pending_book_version, book: book) }
  let (:rejected_book) { FactoryGirl.create(:rejected_book, author: author) }
  let (:rejected_version) { rejected_book.rejected_version }

  let (:attributes) do
    {
      title: 'New title', 
      short_description: 'This is short',
      long_description: 'This is long'
    }
  end

  context 'for an authenticated author' do
    describe 'get :index' do
      it 'is successful' do
        sign_in book.author
        get :index, book_id: book
        expect(response).to have_http_status :success
      end
    end
    context 'that owns the book' do
      before(:each) { sign_in author }

      context 'that is pending approval' do
        describe 'get :show' do
          it 'is successul' do
            get :show, id: pending_version
            expect(response).to have_http_status :success
          end
        end

        describe 'get :new' do
          it 'redirects to the edit page' do
            get :new, book_id: pending_version.book
            expect(response).to redirect_to edit_book_version_path(pending_version)
          end
        end

        describe 'post :create' do
          it 'redirects to the iedit page' do
            post :create, book_id: pending_version.book, book_version: attributes
            expect(response).to redirect_to edit_book_version_path(pending_version)
          end

          it 'does not create a new BookVersion record' do
            pending_version # pre-load the version
            expect do
              post :create, book_id: pending_version.book, book_version: attributes
            end.not_to change(book.versions, :count)
          end
        end

        describe 'get :edit' do
          it 'is successful' do
            get :edit, id: pending_version
            expect(response).to have_http_status :success
          end
        end

        describe 'patch :update' do
          it 'redirects to the book page' do
            patch :update, id: pending_version, book_version: attributes
            expect(response).to redirect_to book_path(book)
          end

          it 'updates the pending version of the book' do
            expect do
              patch :update, id: pending_version, book_version: attributes
              pending_version.reload
            end.to change(pending_version, :title).to('New title')
          end
        end
      end

      context 'that is approved' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: book.approved_version
            expect(response).to have_http_status :success
          end
        end

        describe 'get :new' do
          it 'is successful' do
            get :new, book_id: book
            expect(response).to have_http_status :success
          end
        end

        describe 'post :create' do
          it 'redirects to the created book version page' do
            post :create, book_id: book, book_version: attributes
            expect(response).to redirect_to book_version_path(BookVersion.last)
          end

          it 'creates a new BookVersion record' do
            expect do
              post :create, book_id: book, book_version: attributes
            end.to change(book.versions, :count).by(1)
          end
        end

        describe 'get :edit' do
          it 'redirects to the create page' do
            get :edit, id: book.approved_version
            expect(response).to redirect_to new_book_book_version_path(book)
          end
        end

        describe 'patch :update' do
          it 'redirects to the create page' do
            patch :update, id: book.approved_version, book_version: attributes
            expect(response).to redirect_to new_book_book_version_path(book)
          end

          it 'does not update the book version' do
            expect do
              patch :update, id: book.approved_version, book_version: attributes
              book.approved_version.reload
            end.not_to change(book.approved_version, :updated_at)
          end
        end
      end

      context 'that is rejected' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: rejected_book.rejected_version
            expect(response).to have_http_status :success
          end
        end

        describe 'get :new' do
          it 'is successful' do
            get :new, book_id: book
            expect(response).to have_http_status :success
          end
        end

        describe 'post :create' do
          it 'redirects to the created book version page' do
            post :create, book_id: book, book_version: attributes
            expect(response).to redirect_to book_version_path(BookVersion.last)
          end

          it 'creates a new BookVersion record' do
            expect do
              post :create, book_id: book, book_version: attributes
            end.to change(book.versions, :count).by(1)
          end
        end

        describe 'get :edit' do
          it 'redirects to the new page' do
            get :edit, id: rejected_book.rejected_version
            expect(response).to redirect_to new_book_book_version_path(rejected_book)
          end
        end

        describe 'patch :update' do
          it 'redirects to the create page' do
            patch :update, id: rejected_book.rejected_version, book_version: attributes
            expect(response).to redirect_to new_book_book_version_path(rejected_book)
          end

          it 'does not update the book version' do
            expect do
              patch :update, id: rejected_book.rejected_version, book_version: attributes
              rejected_book.rejected_version.reload
            end.not_to change(rejected_book.rejected_version, :updated_at)
          end
        end
      end
    end # context: that owns the book

    context 'that does not own the book' do
      let (:other_author) { FactoryGirl.create(:approved_author) }
      before(:each) { sign_in other_author }

      describe 'get :new' do
        it 'redirects to the home page' do
          get :new, book_id: book
          expect(response).to redirect_to author_root_path
        end
      end

      describe 'post :create' do
        it 'redirects to the home page' do
          post :create, book_id: book, book_version: attributes
          expect(response).to redirect_to author_root_path
        end

        it 'does not create a new BookVersion record' do
          book # preload the book and version
          expect do
            post :create, book_id: book, book_version: attributes
          end.not_to change(BookVersion, :count)
        end
      end

      context 'that is pending approval' do
        describe 'get :show' do
          it 'redirects to the home page' do
            get :show, id: pending_version
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: pending_version
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: pending_version, book_version: attributes
            expect(response).to redirect_to author_root_path
          end

          it 'does not update the pending version of the book' do
            expect do
              patch :update, id: pending_version, book_version: attributes
              pending_version.reload
            end.not_to change(pending_version, :title)
          end
        end
      end

      context 'that is approved' do
        describe 'get :show' do
          it 'is successful' do
            get :show, id: approved_version
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: approved_version
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the homepage' do
            patch :update, id: approved_version, book_version: attributes
            expect(response).to redirect_to author_root_path
          end

          it 'does not update the book version' do
            expect do
              patch :update, id: approved_version, book_version: attributes
              approved_version.reload
            end.not_to change(approved_version, :title)
          end
        end
      end

      context 'that is rejected' do
        describe 'get :show' do
          it 'redirects to the home page' do
            get :show, id: rejected_version
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'get :edit' do
          it 'redirects to the home page' do
            get :edit, id: rejected_version
            expect(response).to redirect_to author_root_path
          end
        end

        describe 'patch :update' do
          it 'redirects to the home page' do
            patch :update, id: rejected_version, book_version: attributes
            expect(response).to redirect_to author_root_path
          end

          it 'does not update the book version' do
            expect do
              patch :update, id: rejected_version, book_version: attributes
              rejected_version.reload
            end.not_to change(rejected_version, :title)
          end
        end
      end
    end # context: that does not own the book
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the home page' do
        get :index, book_id: book
        expect(response).to redirect_to root_path
      end
    end

    describe 'get :new' do
      it 'redirects to the home page'
    end

    describe 'post :create' do
      it 'redirects to the home page'
      it 'does not create a new BookVersion record'
    end

    context 'for a book that is pending' do
      describe 'get :show' do
        it 'redirects to the home page' do
          get :show, id: pending_version
          expect(response).to redirect_to root_path
        end
      end

      describe 'get :edit' do
        it 'redirects to the home page' do
          get :edit, id: pending_version
          expect(response).to redirect_to root_path
        end
      end

      describe 'patch :update' do
        it 'redirects to the home page' do
          patch :update, id: pending_version, book_version: attributes
          expect(response).to redirect_to root_path
        end

        it 'does not update the book version' do
          expect do
            patch :update, id: pending_version, book_version: attributes
            pending_version.reload
          end.not_to change(pending_version, :title)
        end
      end
    end
  end
end
