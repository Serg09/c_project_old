require 'rails_helper'

RSpec.describe BookCreator do
  let (:author) { FactoryGirl.create(:approved_user) }
  let (:image_file) { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg') }
  let (:sample_file) { Rails.root.join('spec', 'fixtures', 'files', 'sample.pdf') }
  let (:genre1) { FactoryGirl.create(:genre) }
  let (:genre2) { FactoryGirl.create(:genre) }
  let (:genre3) { FactoryGirl.create(:genre) }
  let (:genre4) { FactoryGirl.create(:genre) }
  let (:attributes) do
    {
      title: 'My book', 
      short_description: 'short description',
      long_description: 'long description',
      cover_image_file: image_file,
      sample_file: sample_file,
      genres: [genre1, genre2].map(&:id)
    }
  end

  it 'can be created with an author and valid attributes' do
    creator = BookCreator.new(author, attributes)
    expect(creator).to be_valid
  end

  describe '#title' do
    it 'is required' do
      creator = BookCreator.new(author, attributes.except(:title))
      expect(creator).not_to be_valid
      expect(creator.errors[:title]).to have_at_least(1).item
    end
  end

  describe '#create' do
    context 'with valid attributes' do
      it 'creates a new book record' do
        expect do
          creator = BookCreator.new(author, attributes)
          creator.create
        end.to change(author.books, :count).by(1)
      end

      it 'creates a new book version record' do
        expect do
          creator = BookCreator.new(author, attributes)
          creator.create
        end.to change(BookVersion, :count).by(1)
      end

      it 'returns true' do
        creator = BookCreator.new(author, attributes)
        expect(creator.create).to be true
      end
    end

    context 'with invalid attributes' do
      it 'does not create a book record' do
        expect do
          creator = BookCreator.new(author, attributes.except(:title))
          creator.create
        end.not_to change(Book, :count)
      end

      it 'does not create a book version record' do
        expect do
          creator = BookCreator.new(author, attributes.except(:title))
          creator.create
        end.not_to change(BookVersion, :count)
      end

      it 'returns false' do
        creator = BookCreator.new(author, attributes.except(:title))
        expect(creator.create).to be false
      end
    end
  end

  describe '#book' do
    it 'returns a reference to the book' do
      creator = BookCreator.new(author, attributes)
      expect(creator.book).to be_a(Book)
    end
  end

  describe '#book_version' do
    it 'returns a reference to the book version' do
      creator = BookCreator.new(author, attributes)
      expect(creator.book_version).to be_a(BookVersion)
    end
  end

  describe '#sample_file' do
    it 'must be a PDF' do
      creator = BookCreator.new(author, attributes.merge(sample_file: image_file))
      expect(creator).not_to be_valid
      expect(creator.errors[:sample_file]).to have_at_least(1).item
    end
  end

  describe '#cover_image_file' do
    it 'must be an image file' do
      creator = BookCreator.new(author, attributes.merge(cover_image_file: sample_file))
      expect(creator).not_to be_valid
      expect(creator.errors[:cover_image_file]).to have_at_least(1).item
    end
  end

  describe '#genres' do
    it 'cannot contain more than 3 genres' do
      creator = BookCreator.new(author, attributes.merge(genres: [genre1, genre2, genre3, genre4].map(&:id)))
      expect(creator).not_to be_valid
      expect(creator.errors[:genres]).to have_at_least(1).item
    end
  end
end
