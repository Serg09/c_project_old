require 'rails_helper'

RSpec.describe Bio, type: :model do
  let (:author) { FactoryGirl.create(:author) }
  let (:attributes) do
    {
      author_id: author.id,
      text: 'This is some stuff about me. Dig it.',
      links: [
        {site: :facebook, url: 'http://www.facebook.com/john_doe' },
        {site: :twitter, url: 'http://www.twitter.com/doe_john' }
      ]
    }
  end

  it 'can be created from valid attributes' do
    bio = Bio.new(attributes)
    expect(bio).to be_valid
  end

  describe '#author_id' do
    it 'is required' do
      bio = Bio.new(attributes.except(:author_id))
      expect(bio).to have_at_least(1).error_on :author_id
    end

    it 'points to an author record' do
      bio = Bio.new(attributes)
      expect(bio.author.first_name).to eq author.first_name
    end
  end

  describe '#text' do
    it 'is required' do
      bio = Bio.new(attributes.except(:text))
      expect(bio).to have_at_least(1).error_on :text
    end
  end

  describe '#photo' do
    it 'is a reference to a photo'
  end

  describe '#links' do
    it 'is a collection of links to social media sites' do
      bio = Bio.new(attributes)
      expect(bio).to have(2).links
    end

    it 'rejects items that are missing :site' do
      bio = Bio.new attributes.merge(links: [{url: 'http://www.facebook.com/john_doe'}])
      expect(bio).to have_at_least(1).error_on :links
    end

    it 'rejects items that are missing :url' do
      bio = Bio.new attributes.merge(links: [{site: 'Facebook'}])
      expect(bio).to have_at_least(1).error_on :links
    end
  end
end
