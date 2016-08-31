require 'rails_helper'

RSpec.describe Admin::AuthorsController, type: :controller do
  let (:admin) { FactoryGirl.create(:administrator) }
  let (:author) { FactoryGirl.create(:author) }
  let (:attributes) do
    {
      first_name: 'Humphrey',
      last_name: 'Doe'
    }
  end

  context 'for an authenticated administrator' do
    before(:each) { sign_in admin }

    describe "GET #index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST #create' do
      it 'redirects to the author index page' do
        post :create, author: attributes
        expect(response).to redirect_to admin_authors_path
      end

      it 'creates a new author record' do
        expect do
          post :create, author: attributes
        end.to change(Author, :count).by(1)
      end
    end

    describe "GET #show" do
      it "returns http success" do
        get :show, id: author
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET #edit" do
      it "returns http success" do
        get :edit, id: author
        expect(response).to have_http_status(:success)
      end
    end

    describe 'PATCH #update' do
      it 'redirects to the author index page' do
        patch :update, id: author, author: attributes
        expect(response).to redirect_to admin_authors_path
      end

      it 'updates the author record' do
        expect do
          patch :update, id: author, author: attributes
          author.reload
        end.to change(author, :first_name).to('Humphrey')
      end
    end

    describe 'DELETE #destroy' do
      let!(:author) { FactoryGirl.create(:author) }

      it 'redirects to the author index page' do
        delete :destroy, id: author
        expect(response).to redirect_to admin_authors_path
      end

      it 'removes the author record' do
        expect do
          delete :destroy, id: author
        end.to change(Author, :count).by(-1)
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "GET #index" do
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
    end

    describe "GET #new" do
      it "redirects to the home page" do
        get :new
        expect(response).to redirect_to root_path
      end
    end

    describe 'POST #create' do
      it "redirects to the home page" do
        post :create, author: attributes
        expect(response).to redirect_to root_path
      end

      it 'does not create a new author record' do
        expect do
          post :create, author: attributes
        end.not_to change(Author, :count)
      end
    end

    describe "GET #show" do
      it "redirects to the home page" do
        get :show, id: author
        expect(response).to redirect_to root_path
      end
    end

    describe "GET #edit" do
      it "redirects to the home page" do
        get :edit, id: author
        expect(response).to redirect_to root_path
      end
    end

    describe 'PATCH #update' do
      it "redirects to the home page" do
        patch :update, id: author, author: attributes
        expect(response).to redirect_to root_path
      end

      it 'does not update the author record' do
        expect do
          patch :update, id: author, author: attributes
          author.reload
        end.not_to change(author, :first_name)
      end
    end

    describe 'DELETE #destroy' do
      it "redirects to the home page" do
        delete :destroy, id: author
        expect(response).to redirect_to root_path
      end

      it 'does not remove the author record' do
        expect do
          delete :destroy, id: author
        end.not_to change(Author, :count)
      end
    end
  end
end
