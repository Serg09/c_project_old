require 'rails_helper'

RSpec.describe Admin::BookVersionsController, type: :controller do
  let (:author) { FactoryGirl.create(:user) }
  let (:book) { FactoryGirl.create(:pending_book, author: author) }
  let (:pending_book_version) { book.pending_version }

  shared_context 'administrative book' do
    let (:author) { FactoryGirl.create(:author) }
    let (:book) { FactoryGirl.create(:book, author: author) }
    let (:book_version) { FactoryGirl.create(:approved_book_version, book: book) }
    let (:attributes) do
      {
        title: 'War and Peace',
        short_description: 'It is a book.',
        long_description: 'It is a really long book about really heavy topics.'
      }
    end
  end

  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe 'get :index' do
      it 'is successful' do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'PATCH #update' do
      include_context 'administrative book'

      it 'redirects to the author books index page' do
        patch :update, id: book_version, book_version: attributes
        expect(response).to redirect_to admin_author_books_path(author)
      end

      it 'updates the book version' do
        expect do
          patch :update, id: book_version, book_version: attributes
          book_version.reload
        end.to change(book_version, :title).to('War and Peace')
      end
    end

    describe 'patch :approve' do
      it 'redirects to the book index page' do
        patch :approve, id: pending_book_version
        expect(response).to redirect_to admin_book_versions_path
      end

      it 'changes the status of the book to "approved"' do
        expect do
          patch :approve, id: pending_book_version
          pending_book_version.reload
        end.to change(pending_book_version, :status).to 'approved'
      end
    end

    describe 'patch :reject' do
      it 'redirects to the book index page' do
        patch :reject, id: pending_book_version
        expect(response).to redirect_to admin_book_versions_path
      end

      it 'changes the status of the book to "rejected"' do
        expect do
          patch :reject, id: pending_book_version
          pending_book_version.reload
        end.to change(pending_book_version, :status).from('pending').to('rejected')
      end

      it 'changes the status of the book version to "rejected"' do
        expect do
          patch :reject, id: pending_book_version
          pending_book_version.reload
        end.to change(pending_book_version, :status).from('pending').to('rejected')
      end
    end
  end

  context 'for an unauthenticated user' do
    describe 'get :index' do
      it 'redirects to the home page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'PATCH #update' do
      include_context 'administrative book'

      it 'redirects to the home page' do
        patch :update, id: book_version, book_version: attributes
        expect(response).to redirect_to root_path
      end

      it 'does not update the book version' do
        expect do
          patch :update, id: book_version, book_version: attributes
          book_version.reload
        end.not_to change(book_version, :title)
      end
    end

    describe 'patch :approve' do
      it 'redirects to the home page' do
        patch :approve, id: pending_book_version
        expect(response).to redirect_to root_path
      end

      it 'does not update the book' do
        expect do
          patch :approve, id: pending_book_version
          pending_book_version.reload
        end.not_to change(pending_book_version, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the home page' do
        patch :reject, id: pending_book_version
        expect(response).to redirect_to root_path
      end

      it 'does not update the book' do
        expect do
          patch :reject, id: pending_book_version
          pending_book_version.reload
        end.not_to change(pending_book_version, :status)
      end
    end
  end
end
