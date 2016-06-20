require 'rails_helper'

RSpec.describe ContributionsController, type: :controller do
  let (:author) { FactoryGirl.create(:user) }
  let (:bio) { FactoryGirl.create(:approved_bio) }
  let (:book) { FactoryGirl.create(:approved_book, author: author) }
  let (:campaign) { FactoryGirl.create(:campaign, book: book) }
  let (:contribution) { FactoryGirl.create(:contribution, campaign: campaign) }
  let (:attributes) do
    {
      email: Faker::Internet.email,
      amount: 100,
      credit_card: '4444111144441111',
      credit_card_type: 'visa',
      expiration_month: '5',
      expiration_year: '2020',
      cvv: '123',
      first_name: 'John',
      last_name: 'Doe',
      address_1: '1234 Main Str',
      address_2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200'
    }
  end

  context 'for an unauthenticated user' do
    describe 'get :new' do
      it 'is successful' do
        get :new, campaign_id: campaign
        expect(response).to have_http_status :success
      end
    end

    describe 'post :create' do
      it 'redirects to the book page' do
        post :create, campaign_id: campaign, contribution: attributes
        expect(response).to redirect_to book_path(campaign.book_id)
      end

      it 'creates a contribution record' do
        expect do
          post :create, campaign_id: campaign, contribution: attributes
        end.to change(campaign.contributions, :count).by(1)
      end

      it 'creates a payment record' do
        expect do
          post :create, campaign_id: campaign, contribution: attributes
        end.to change(Payment, :count).by(1)
      end
    end
  end
end
