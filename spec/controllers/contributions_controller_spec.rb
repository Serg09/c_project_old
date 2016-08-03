require 'rails_helper'

RSpec.describe ContributionsController, type: :controller do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let!(:physical_reward) { FactoryGirl.create(:physical_reward, campaign: campaign) }
  let!(:electronic_reward) { FactoryGirl.create(:electronic_reward, campaign: campaign) }

  let (:attributes) do
    {
      email: 'john@doe.com',
      amount: 100
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
      postal_code: '75201',
      country_code: 'US'
    }
  end

  let (:electronic_fulfillment_attributes) do
    {
      reward_id: electronic_reward.id,
      email: 'john@doe.com'
    }
  end

  describe 'get :new' do
    it 'is successful' do
      get :new, campaign_id: campaign
      expect(response).to have_http_status :success
    end
  end

  describe 'post :create' do
    context 'in json' do
      it 'returns the contribution' do
        post :create, campaign_id: campaign,
                      contribution: attributes,
                      format: :json
        contribution = JSON.parse(response.body, symbolize_names: true)
        expect(contribution).to include(campaign_id: campaign.id,
                                        amount: '100.0',
                                        email: 'john@doe.com')
      end
      it 'creates a contribution record' do
        expect do
          post :create, campaign_id: campaign,
                        contribution: attributes,
                        format: :json
        end.to change(campaign.contributions, :count).by(1)
      end

      context 'when an electronic reward is specified' do
        it 'creates an electronic fulfillment record' do
          expect do
            post :create, campaign_id: campaign,
                          contribution: attributes,
                          fulfillment: electronic_fulfillment_attributes,
                          format: :json
          end.to change(ElectronicFulfillment, :count).by(1)
        end
      end

      context 'when a physical reward is specified' do
        it 'creates a physical fulfillment record' do
          expect do
            post :create, campaign_id: campaign,
                          contribution: attributes,
                          fulfillment: physical_fulfillment_attributes,
                          format: :json
          end.to change(PhysicalFulfillment, :count).by(1)
        end
      end
    end
  end
end
