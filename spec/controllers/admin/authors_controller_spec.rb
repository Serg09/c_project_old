require 'rails_helper'

RSpec.describe Admin::AuthorsController, type: :controller do
  let (:author) { FactoryGirl.create(:pending_author) }
  let (:admin) { FactoryGirl.create(:administrator) }

  context 'for an authenticated author' do
    before(:each) { sign_in author} 

    describe "get :index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :approve' do
      it 'redirects to the author root page' do
        patch :approve, id: author
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the author' do
        expect do
          patch :approve, id: author
          author.reload
        end.not_to change(author, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the author root page' do
        patch :reject, id: author
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the author' do
        expect do
          patch :reject, id: author
          author.reload
        end.not_to change(author, :status)
      end
    end
  end

  context 'for an authenticated administrator' do
    before(:each) { sign_in admin }

    describe "get :index" do
      it "is successful" do
        get :index
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :approve' do
      it 'redirects to the authors index page' do
        patch :approve, id: author
        expect(response).to redirect_to admin_authors_path
      end

      it 'changes the status of the author to "approveed"' do
        expect do
          patch :approve, id: author
          author.reload
        end.to change(author, :status).to Author.APPROVED
      end
    end

    describe 'patch :reject' do
      it 'redirects to the authors index page' do
        patch :reject, id: author
        expect(response).to redirect_to admin_authors_path
      end

      it 'changes the status of the author to "rejected"' do
        expect do
          patch :reject, id: author
          author.reload
        end.to change(author, :status).to Author.REJECTED
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe 'patch :approve' do
      it 'redirects to the home page' do
        patch :approve, id: author
        expect(response).to redirect_to root_path
      end

      it 'does not change the status of the author' do
        expect do
          patch :approve, id: author
          author.reload
        end.not_to change(author, :status)
      end
    end

    describe 'patch :reject' do
      it 'redirects to the home page' do
        patch :reject, id: author
        expect(response).to redirect_to root_path
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
