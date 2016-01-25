require 'rails_helper'

RSpec.describe Link, type: :model do

  let (:bio) { FactoryGirl.create(:bio) }

  let (:attributes) do
    {
      bio_id: bio.id,
      site: Link.FACEBOOK,
      url: 'www.facebook.com/somethingcool'
    }
  end

  it 'can be created from valid attributes' do
    link = Link.new(attributes)
    expect(link).to be_valid
  end

  describe '#bio_id' do
    it 'is required' do
      link = Link.new(attributes.except(:bio_id))
      expect(link).to have_at_least(1).error_on :bio_id
    end

    it 'points to a bio record' do
      link = Link.new(attributes)
      expect(link.bio.id).to eq bio.id
    end
  end

  describe '#site' do
    it 'is required' do

    end

    it 'must be a valid site (Facebook, LinkedIn, Twitter, Instagram, Tumblr)'
  end

  describe '#url' do
    it 'is required'
    it 'must be a valid URL'
    it 'just have the correct domain name for the selected site'
  end
end
