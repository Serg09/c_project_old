require 'rails_helper'

RSpec.describe Admin::BookVersionsController, type: :controller do
  let (:author) { FactoryGirl.create(:user) }
  let (:book) { FactoryGirl.create(:pending_book, author: author) }
  let (:pending_book_version) { book.pending_version }

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
        end.to change(pending_book_version, :status).to BookVersion.REJECTED
      end

      it 'changes the status of the book version to "rejected"' do
        expect do
          patch :reject, id: pending_book_version
          pending_book_version.reload
        end.to change(pending_book_version, :status).to BookVersion.REJECTED
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
