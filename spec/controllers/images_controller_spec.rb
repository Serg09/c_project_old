require 'rails_helper'

RSpec.describe ImagesController, type: :controller do
  let (:author) { FactoryGirl.create(:author) }
  let (:unapproved_image) { FactoryGirl.create(:image, author: author) }
  let (:approved_image) { FactoryGirl.create(:image, author: author) }
  let!(:bio) { FactoryGirl.create(:approved_bio, author: author, photo_id: approved_image.id) }

  context 'for an image associated with an approved bio' do
    describe "get :show" do
      it "is successful" do
        get :show, id: approved_image.id
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'for an image not associate with an approved bio' do
    describe 'get :show' do
      it 'returns "resource not found"' do
        get :show, id: unapproved_image.id
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
