require 'rails_helper'

RSpec.describe CampaignsController, type: :controller do
  let (:author) { FactoryGirl.create(:approved_author) }
  let (:book) { FactoryGirl.create(:approved_book, author: author) }
  let (:campaign) { FactoryGirl.create(:campaign, book: book) }
  let (:attributes) do
    {
      target_date: '3/31/2016',
      target_amount: 5_000
    }
  end

  context 'for an authenticated author' do
    context 'that owns the book' do
      before(:each) { sign_in author  }

      describe "get :index" do
        it "returns http success" do
          get :index, book_id: book
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :new" do
        it "returns http success" do
          get :new, book_id: book
          expect(response).to have_http_status(:success)
        end
      end

      describe "post :create" do
        it "redirects to the index page" do
          post :create, book_id: book, campaign: attributes
          expect(response).to redirect_to book_campaigns_path(book)
        end

        it 'creates a new campain record' do
          expect do
            post :create, book_id: book, campaign: attributes
          end.to change(book.campaigns, :count).by(1)
        end
      end

      describe "get :show" do
        it "returns http success" do
          get :show, id: campaign
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :edit" do
        it "returns http success" do
          get :edit, id: campaign
          expect(response).to have_http_status(:success)
        end
      end

      describe "patch :update" do
        it "redirects to the index page" do
          patch :update, id: campaign, campaign: attributes
          expect(response).to redirect_to book_campaigns_path(book)
        end

        it 'updates the campaign' do
          expect do
            patch :update, id: campaign, campaign: attributes
            campaign.reload
          end.to change(campaign, :target_amount).to 5_000
        end
      end

      describe "delete :destroy" do
        it "redirects to the index page" do
          delete :destroy, id: campaign
          expect(response).to redirect_to book_campaigns_path(book)
        end

        it 'removes the campaign record' do
          campaign #reload the campaign
          expect do
            delete :destroy, id: campaign
          end.to change(Campaign, :count).by(-1)
        end
      end
    end

    context 'that does not own the book' do
      let (:other_author) { FactoryGirl.create(:approved_author) }
      before(:each) { sign_in other_author  }

      describe "get :index" do
        it "redirects to the 404 error page" do
          expect do
            get :index, book_id: book
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      describe "get :new" do
        it "redirects to the 404 error page" do
          expect do
            get :new, book_id: book
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      describe "post :create" do
        it "redirects to the 404 error page" do
          expect do
            post :create, book_id: book, campaign: attributes
          end.to raise_error ActiveRecord::RecordNotFound
        end

        it 'does not create a new campain record' do
          expect do
            begin
              post :create, book_id: book, campaign: attributes
            rescue ActiveRecord::RecordNotFound
            end
          end.not_to change(Campaign, :count)
        end
      end

      describe "get :show" do
        it "redirects to the 404 error page" do
          expect do
            get :show, id: campaign
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      describe "get :edit" do
        it "redirects to the 404 error page" do
          expect do
            get :edit, id: campaign
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      describe "patch :update" do
        it "redirects to the 404 error page" do
          expect do
            patch :update, id: campaign, campaign: attributes
          end.to raise_error ActiveRecord::RecordNotFound
        end

        it 'does not update the campaign' do
          expect do
            begin
              patch :update, id: campaign, campaign: attributes
              campaign.reload
            rescue ActiveRecord::RecordNotFound
            end
          end.not_to change(campaign, :target_amount)
        end
      end

      describe "delete :destroy" do
        it "redirects to the 404 error page" do
          expect do
            delete :destroy, id: campaign
          end.to raise_error ActiveRecord::RecordNotFound
        end

        it 'does not remove the campaign record' do
          campaign #reload the campaign
          expect do
            begin
              delete :destroy, id: campaign
            rescue ActiveRecord::RecordNotFound
            end
          end.not_to change(Campaign, :count)
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the author sign in page" do
        get :index, book_id: book
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "get :new" do
      it "redirects to the author sign in page" do
        get :new, book_id: book
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "post :create" do
      it "redirects to the index page" do
        post :create, book_id: book
        expect(response).to redirect_to new_author_session_path
      end

      it 'does not create a new campain record' do
        expect do
          post :create, book_id: book
        end.not_to change(Campaign, :count)
      end
    end

    describe "get :show" do
      it "redirects to the author sign in page" do
        get :show, id: campaign
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "get :edit" do
      it "redirects to the author sign in page" do
        get :edit, id: campaign
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "patch :update" do
      it "redirects to the author sign in page" do
        patch :update, id: campaign, campaign: attributes
        expect(response).to redirect_to new_author_session_path
      end

      it 'does not update the campaign' do
        expect do
          patch :update, id: campaign, campaign: attributes
          campaign.reload
        end.not_to change(campaign, :target_amount)
      end
    end

    describe "delete :destroy" do
      it "redirects to the author sign in page" do
        delete :destroy, id: campaign
        expect(response).to redirect_to new_author_session_path
      end

      it 'does not remove the campaign record' do
        campaign #reload the campaign
        expect do
          delete :destroy, id: campaign
        end.not_to change(Campaign, :count)
      end
    end
  end
end
