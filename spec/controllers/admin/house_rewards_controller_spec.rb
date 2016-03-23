require 'rails_helper'

RSpec.describe Admin::HouseRewardsController, type: :controller do
  let (:house_reward) { FactoryGirl.create(:house_reward) }
  let (:attributes) do
    {
      description: 'Jelly of the Month Club Membership',
      physical_address_required: true
    }
  end

  context 'for an authenticated administrator' do
    let (:admin) { FactoryGirl.create(:administrator) }
    before(:each) { sign_in admin }

    describe "get :index" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    describe "get :new" do
      it "returns http success" do
        get :new
        expect(response).to have_http_status(:success)
      end
    end

    describe "post :create" do
      it "creates a new house reward record" do
        expect do
          post :create, house_reward: attributes
        end.to change(HouseReward, :count).by(1)
      end

      it 'redirects to the house rewards index page' do
        post :create, house_reward: attributes
        expect(response).to redirect_to admin_house_rewards_path
      end
    end

    describe "get :edit" do
      it "returns http success" do
        get :edit, id: house_reward
        expect(response).to have_http_status(:success)
      end
    end

    describe "patch :update" do
      it 'updates the house reward record' do
        expect do
          patch :update, id: house_reward, house_reward: attributes
          house_reward.reload
        end.to change(house_reward, :description).to attributes[:description]
      end

      it 'redirects to the house rewards index page' do
        patch :update, id: house_reward, house_reward: attributes
        expect(response).to redirect_to admin_house_rewards_path
      end
    end

    describe "get :show" do
      it "returns http success" do
        get :show, id: house_reward
        expect(response).to have_http_status(:success)
      end
    end

    describe "delete :destroy" do
      it 'removes the house reward record' do
        house_reward # force load
        expect do
          delete :destroy, id: house_reward
        end.to change(HouseReward, :count).by(-1)
      end

      it "redirects to the house rewards index page" do
        delete :destroy, id: house_reward
        expect(response).to redirect_to admin_house_rewards_path
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

    describe "get :new" do
      it "redirects to the home page" do
        get :new
        expect(response).to redirect_to root_path
      end
    end

    describe "post :create" do
      it "does not create a new house reward record" do
        expect do
          post :create, house_reward: attributes
        end.not_to change(HouseReward, :count)
      end

      it "redirects to the home page" do
        post :create, house_reward: attributes
        expect(response).to redirect_to root_path
      end
    end

    describe "get :edit" do
      it "redirects to the home page" do
        get :edit, id: house_reward
        expect(response).to redirect_to root_path
      end
    end

    describe "patch :update" do
      it 'does not update the house reward record' do
        expect do
          patch :update, id: house_reward, house_reward: attributes
          house_reward.reload
        end.not_to change(house_reward, :description)
      end

      it "redirects to the home page" do
        patch :update, id: house_reward, house_reward: attributes
        expect(response).to redirect_to root_path
      end
    end

    describe "get :show" do
      it "redirects to the home page" do
        get :show, id: house_reward
        expect(response).to redirect_to root_path
      end
    end

    describe "delete :destroy" do
      it 'does not remove the house reward record' do
        house_reward # force load
        expect do
          delete :destroy, id: house_reward
        end.not_to change(HouseReward, :count)
      end

      it "redirects to the home page" do
        delete :destroy, id: house_reward
        expect(response).to redirect_to root_path
      end
    end
  end
end
