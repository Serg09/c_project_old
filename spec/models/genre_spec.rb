require 'rails_helper'

RSpec.describe Genre, type: :model do
  let (:attributes) do
    {
      name: 'Mystery'
    }
  end

  it 'can be created from valid attributes' do
    genre = Genre.new(attributes)
    expect(genre).to be_valid
  end

  describe '#name' do
    it 'is required' do
      genre = Genre.new attributes.except(:name)
      expect(genre).to have_at_least(1).error_on :name
    end

    it 'must be unique' do
      g1 = Genre.create! attributes
      g2 = Genre.new attributes
      expect(g2).to have_at_least(1).error_on :name
    end

    it 'cannot be more than 50 characters' do
      genre = Genre.new attributes.merge(name: "x" * 51)
      expect(genre).to have_at_least(1).error_on :name

      genre = Genre.new attributes.merge(name: "x" * 50)
      expect(genre).to be_valid
    end
  end

  describe '#book_versions' do
    it 'is a list of books having this genre' do
      genre = Genre.new attributes
      expect(genre).to have(0).book_versions
    end
  end
end
