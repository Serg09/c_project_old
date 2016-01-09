require 'spec_helper'

describe Inquiry do
  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@doe.com',
      body: 'Please help me. You\'re my only hope'
    }
  end

  it 'is creatable from valid attributes' do
    inquiry = Inquiry.new attributes
    expect(inquiry).to be_valid
  end

  describe '#first_name' do
    it 'is required' do
      inquiry = Inquiry.new attributes.except(:first_name)
      expect(inquiry).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      inquiry = Inquiry.new attributes.except(:last_name)
      expect(inquiry).to have_at_least(1).error_on :last_name
    end
  end

  describe '#email' do
    it 'is required' do
      inquiry = Inquiry.new attributes.except(:email)
      expect(inquiry).to have_at_least(1).error_on :email
    end
  end

  describe '#body' do
    it 'is required' do
      inquiry = Inquiry.new attributes.except(:body)
      expect(inquiry).to have_at_least(1).error_on :body
    end
  end

  describe '#archived?' do
    it 'defaults to false' do
      inquiry = Inquiry.new attributes
      expect(inquiry).not_to be_archived
    end
  end
end
