require 'rails_helper'

RSpec.describe BookVersionsController, type: :controller do
  let (:author) { FactoryGirl.create(:approved_author) }
  let (:book) { FactoryGirl.create(:approved_book, author: author) }
  let (:pending_version) { FactoryGirl.create(:pending_book_version, book: book) }
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
        get :index
        expect(response).to have_http_status :success
      end
    end

    context 'that owns the book' do
      before(:each) { sign_in author }

      context 'that is pending approval' do
        describe 'get :show' do
          it 'is successul' do
            get :show, id: pending_version
            expoect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'is successful' do
            get :edit, id: pending_
            expect(response).to have_http_status :success
          end
        end

        describe 'patch :update' do
          it 'redirects to the book page' do
            patch :update, id: pending_version, book: book_attributes
            expect(response).to redirect_to book_path(book)
          end

          it 'updates the pending version of the book' do
            expect do
              patch :update, id: pending_version, book: attributes
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

        describe 'get :edit' do
          it 'redirects to the create page' do
            get :edit, id: book.approved_version
            expect(response).to redirect_to create_book_book_version_path(book)
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
        let (:rejected_book) { FactoryGirl.create(:rejected_book, author: author) }

        describe 'get :show' do
          it 'is successful' do
            get :show, id: rejected_book.rejected_version
            expect(response).to have_http_status :success
          end
        end

        describe 'get :edit' do
          it 'redirects to the create page' do
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

      context 'that is pending approval' do
        describe 'get :show' do
          it 'redirects to the home page'
        end

        describe 'get :edit' do
          it 'redirects to the home page'
        end

        describe 'patch :update' do
          it 'redirects to the home page'
          it 'does not update the pending version of the book'
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
          it 'redirects to the homepage'
          it 'does not update the book version'
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
          it 'does not update the book version'
        end
      end
    end # context: that does not own the book
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the home page'
    end

    context 'for a book that is pending' do
      describe 'get :show' do
        it 'redirects to the home page'
      end
      describe 'get :edit' do
        it 'redirects to the home page'
      end
      describe 'patch :update' do
        it 'redirects to the home page'
        it 'does not update the book version'
      end
    end
  end
end
