require 'rails_helper'

RSpec.describe Admin::BooksController, type: :controller do
  let (:author) { FactoryGirl.create(:approved_author) }
  let (:pending_book) { FactoryGirl.create(:pending_book, author: author) }

  context 'for an authenticated author' do
    before(:each) { sign_in author }

    describe 'get :index' do
      it 'redirects to the home page' do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :approve' do
      it 'redirects to the home page' do
        patch :approve, id: pending_book
        expect(response).to redirect_to root_path
      end

      it 'does not update the book' do
        expect do
          patch :approve, id: pending_book
          pending_book.reload
        end.not_to change(pending_book, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the home page' do
        patch :reject, id: pending_book
        expect(response).to redirect_to root_path
      end

      it 'does not update the book' do
        expect do
          patch :reject, id: pending_book
          pending_book.reload
        end.not_to change(pending_book, :status)
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
      end
    end

    describe 'patch :approve' do
      it 'redirects to the book index page' do
        patch :approve, id: pending_book
        expect(response).to redirect_to admin_books_path
      end

      it 'changes the status of the book to "approved"' do
        expect do
          patch :approve, id: pending_book
          pending_book.reload
        end.to change(pending_book, :status).to BookVersion.APPROVED
      end
    end

    describe 'patch :reject' do
      it 'redirects to the book index page' do
        patch :reject, id: pending_book
        expect(response).to redirect_to admin_books_path
      end

      it 'changes the status of the book to "rejected"' do
        expect do
          patch :reject, id: pending_book
          pending_book.reload
        end.to change(pending_book, :status).to BookVersion.REJECTED
      end

      it 'changes the status of the book version to "rejected"' do
        version = pending_book.pending_version
        expect do
          patch :reject, id: pending_book
          version.reload
        end.to change(version, :status).to BookVersion.REJECTED
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

    describe 'patch :approve' do
      it 'redirects to the home page' do
        patch :approve, id: pending_book
        expect(response).to redirect_to root_path
      end

      it 'does not update the book' do
        expect do
          patch :approve, id: pending_book
          pending_book.reload
        end.not_to change(pending_book, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the home page' do
        patch :reject, id: pending_book
        expect(response).to redirect_to root_path
      end

      it 'does not update the book' do
        expect do
          patch :reject, id: pending_book
          pending_book.reload
        end.not_to change(pending_book, :status)
      end
    end
  end
end
