require 'rails_helper'

RSpec.describe ContributionsController, type: :controller do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:physical_reward) { FactoryGirl.create(:physical_reward, campaign: campaign) }
  let (:electronic_reward) { FactoryGirl.create(:electronic_reward, campaign: campaign) }

  let (:payment_attributes) do
    {
      credit_card_number: '4444111144441111',
      credit_card_type: 'visa',
      expiration_month: '5',
      expiration_year: '2020',
      cvv: '123',
      address1: '1234 Main Str',
      address2: 'Apt 227',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75200'
    }
  end

  let (:physical_fulfillment_attributes) do
    {
      reward_id: physical_reward.id,
      first_name: 'John',
      last_name: 'Doe',
      address1: 'PO BOX 42',
      city: 'Dallas',
      state: 'TX',
      postal_code: '75201'
    }
  end

  describe 'get :new' do
    it 'is successful' do
      get :new, campaign_id: campaign
      expect(response).to have_http_status :success
    end
  end

  describe 'post :create' do
    # in JSON it will perform full creation and require all attributes in one post
    # in HTML it builds the contribution one step at a time

    context 'when a reward is selected' do
      it 'redirects to the :payment action' do
        post :create, campaign_id: campaign,
                      fulfillment: { reward_id: physical_reward.id },
                      contribution: {}
        expect(response).to redirect_to payment_contribution_path(Contribution.last)
      end
    end

    context 'when an amount is entered' do
      it 'redirects to the :reward action' do
        post :create, campaign_id: campaign,
                      fulfillment: {},
                      contribution: { amount: 100}
        expect(response).to redirect_to reward_contribution_path(Contribution.last)
      end
    end

    it 'creates a contribution record' do
      expect do
        post :create, campaign_id: campaign,
                      fulfillment: {},
                      contribution: { amount: 100}
      end.to change(campaign.contributions, :count).by(1)
    end
  end

  context 'with an incipient contribution' do
    let (:contribution) { FactoryGirl.create(:incipient_contribution, campaign: campaign) }

    describe 'get :reward' do
      it 'is successful' do
        get :reward, id: contribution
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :set_reward' do
      it 'redirects to the payment action' do
        patch :set_reward, id: contribution, fulfillment: { reward_id: electronic_reward.id }
        expect(response).to redirect_to payment_contribution_path(contribution, reward_id: electronic_reward.id)
      end
    end

    describe 'get :payment' do
      it 'is successful' do
        get :payment, id: contribution
        expect(response).to have_http_status :success
      end
    end

    describe 'patch :pay' do
      it 'changes the contribution status to "collected"' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
          contribution.reload
        end.to change(contribution, :state).from('incipient').to('collected')
      end

      it 'creates a payment record' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
        end.to change(Payment, :count).by(1)
      end

      it 'creates a transaction record' do
        expect do
          patch :pay, id: contribution,
                      fulfillment: {},
                      contribution: { email: Faker::Internet.email },
                      payment: payment_attributes
        end.to change(PaymentTransaction, :count).by(1)
      end
    end
  end

  context 'with a pledged contribution' do
    describe 'get :reward' do
      it 'is redirects to the user profile'
    end

    describe 'patch :set_reward' do
      it 'is redirects to the user profile'
      it 'does not change the reward'
    end

    describe 'get :payment' do
      it 'is redirects to the user profile'
    end

    describe 'patch :pay' do
      it 'is redirects to the user profile'
      it 'does not create a payment'
    end
  end
end
