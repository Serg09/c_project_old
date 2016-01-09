require 'rails_helper'

describe InquiriesController do
  describe 'get :new' do
    it 'should be successful' do
      get :new
      expect(response).to be_success
    end
  end
end


