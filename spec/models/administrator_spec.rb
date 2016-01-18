require 'rails_helper'

RSpec.describe Administrator, type: :model do
  let (:attributes) do
    {
      email: "joe@admin.com",
      password: "please01",
      password_confirmation: "please01"
    }
  end

  it 'is creatable from valid attributes' do
    admin = Administrator.new attributes
    expect(admin).to be_valid
  end

  describe '#email' do
    it 'is required' do
      admin = Administrator.new attributes.except(:email)
      expect(admin).to have_at_least(1).error_on :email
    end
  end

  describe '#password' do
    it 'is required' do
      admin = Administrator.new attributes.except(:password)
      expect(admin).to have_at_least(1).error_on :password
    end
  end

  describe '#password_confirmation' do
    it 'must match password' do
      admin = Administrator.new attributes.merge(password_confirmation: 'somethingelse')
      expect(admin).to have_at_least(1).error_on :password_confirmation
    end
  end
end
