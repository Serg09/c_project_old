require 'rails_helper'

RSpec.describe Bio, type: :model do
  let (:author) { FactoryGirl.create(:author) }
  let (:attributes) do
    {
      author_id: author.id,
      text: 'This is some stuff about me. Dig it.'
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
end
