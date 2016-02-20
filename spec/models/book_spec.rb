require 'rails_helper'

RSpec.describe Book, type: :model do
  let (:author) { FactoryGirl.create(:author) }
  let (:attributes) do
    {
      author_id: author.id,
    }
  end

  it 'can be created from valid attributes' do
    book = Book.new attributes
    expect(book).to be_valid
  end

  describe '#author_id' do
    it 'is required' do
      book = Book.new attributes.except(:author_id)
      expect(book).to have_at_least(1).error_on :author_id
    end
  end

  describe '#author' do
    it 'is a reference to the author that owns the book' do
      book = Book.new attributes
      expect(book.author).not_to be_nil
    end
  end

  describe '#versions' do
    it 'is a collection of the versions of the book' do
      book = Book.new attributes
      expect(book).to have(0).versions
    end
  end
end
