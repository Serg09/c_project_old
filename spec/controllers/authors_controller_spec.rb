require 'rails_helper'

RSpec.describe AuthorsController, type: :controller do

  let (:author) { FactoryGirl.create(:author) }

  describe "get :show" do
    it "is successful" do
      get :show, id: author
      expect(response).to have_http_status(:success)
    end
  end

  describe "get :edit" do
    it "returns http success" do
      get :edit, id: author
      expect(response).to have_http_status(:success)
    end
  end

  describe "patch :update" do
    it "updates the specified author"
    it "redirects to the author profile page"
  end

end
