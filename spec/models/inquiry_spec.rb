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

    it 'must be well formatted' do
      inquiry = Inquiry.new attributes.merge(email: 'notvalid')
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

  describe '#full_name' do
    it 'combines the first and last names' do
      inquiry = Inquiry.new attributes
      expect(inquiry.full_name).to eq 'John Doe'
    end
  end

  shared_context :multiple do
    let!(:a1) { FactoryGirl.create(:inquiry, first_name: 'Jane') }
    let!(:a2) { FactoryGirl.create(:inquiry, first_name: 'John') }
    let!(:v1) { FactoryGirl.create(:inquiry, first_name: 'Mike', archived: true) }
    let!(:v2) { FactoryGirl.create(:inquiry, first_name: 'Mark', archived: true) }
  end

  describe '::active' do
    include_context :multiple
    it 'returns the active inquiries' do
      active = Inquiry.active.map(&:first_name)
      expect(active).to eq %w(Jane John)
    end
  end

  describe '::archived' do
    include_context :multiple
    it 'returns the archived inquiries' do
      archived = Inquiry.archived.map(&:first_name)
      expect(archived).to eq %w(Mike Mark)
    end
  end
end
