require 'rails_helper'

RSpec.describe DonationsController, type: :controller do
  let (:author) { bio.author }
  let (:bio) { FactoryGirl.create(:approved_bio) }
  let (:book) { FactoryGirl.create(:approved_book, author: author) }
  let (:campaign) { FactoryGirl.create(:campaign, book: book) }
  let (:donation) { FactoryGirl.create(:donation, campaign: campaign) }
  let (:attributes) { FactoryGirl.attributes_for(:donation, campaign: campaign) }

  context 'for an authenticated author' do
    context 'that owns the associated book' do
      describe "get :index" do
        it "returns http success" do
          get :index, campaign_id: campaign
          expect(response).to have_http_status(:success)
        end
      end

      describe "get :show" do
        it "returns http success" do
          get :show, id: donation
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'that does not own the associated book' do
      describe "get :index" do
        it "raises 'resource not found'" do
          expect do
            get :index, campaign_id: campaign
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      describe "get :show" do
        it "raises 'resource not found'" do
          expect do
            get :show, id: donation
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end

  context 'for an unauthenticated user' do
    describe "get :index" do
      it "redirects to the author sign in page" do
        get :index, campaign_id: campaign
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe "get :show" do
      it "redirects to the author sign in page" do
        get :show, id: donation
        expect(response).to redirect_to new_author_session_path
      end
    end

    describe 'get :new' do
      it 'is successful' do
        get :new, campaign_id: campaign
        expect(response).to have_http_status :success
      end
    end

    describe 'post :create' do
      it 'redirects to the donation show page' do
        post :create, campaign_id: campaign, donation: attributes
        expect(response).to redirect_to donation_page(Donation.last)
      end

      it 'creates a donation record' do
        expect do
          post :create, campaign_id: campaign, donation: attributes
        end.to change(campaign.donations, :count).by(1)
      end
    end
  end
end
