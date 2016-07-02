require 'rails_helper'

RSpec.describe SubscribersController, type: :controller do
  let (:attributes) do
    {
      first_name: 'John', 
      last_name: 'Doe', 
      email: 'John@Doe.com'
    }
  end

  describe 'GET #new' do
    it 'is successful' do
      get :new
      expect(response).to have_http_status :success
    end
  end

  describe "POST #create" do
    it "it redirects to a confirmation page" do
      post :create, subscriber: attributes
      expect(response).to redirect_to subscriber_path(Subscriber.last)
    end

    it 'creates a subscriber record' do
      expect do
        post :create, subscriber: attributes
      end.to change(Subscriber, :count).by(1)
    end
  end

  describe 'GET #show' do
    let (:subscriber) { FactoryGirl.create(:subscriber) }

    it 'is successful' do
      get :show, id: subscriber
      expect(response).to have_http_status :success
    end
  end
end
