require 'rails_helper'

RSpec.describe BookVersion, type: :model do
  let (:book) { FactoryGirl.create(:book) }
  let (:image_file) { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg') }
  let (:sample_file) { Rails.root.join('spec', 'fixtures', 'files', 'sample.pdf') }
  let (:attributes) do
    {
      book_id: book.id,
      title: 'About Me',
      short_description: "It's about me",
      long_description: Faker::Lorem.paragraph
    }
  end

  it 'can be created from valid attributes' do
    book_version = BookVersion.new attributes
    expect(book_version).to be_valid
  end

  describe '#book' do
    it 'is required' do
      book = BookVersion.new attributes.except(:book_id)
      expect(book).to have_at_least(1).error_on :book
    end
  end

  describe '#author' do
    it 'is a reference to the author that owns the book' do
      book = BookVersion.new attributes
      expect(book.author).not_to be_nil
    end
  end

  describe '#title' do
    it 'is required' do
      book = BookVersion.new attributes.except(:title)
      expect(book).to have_at_least(1).error_on :title
    end

    it 'cannot be more than 255 characters' do
      book = BookVersion.new attributes.merge title: "x" * 256
      expect(book).to have_at_least(1).error_on :title

      book = BookVersion.new attributes.merge title: "x" * 255
      expect(book).to be_valid
    end
  end

  describe '#short_description' do
    it 'is required' do
      book = BookVersion.new attributes.except :short_description
      expect(book).to have_at_least(1).error_on :short_description
    end

    it 'cannot be more than 1000 characters' do
      book = BookVersion.new attributes.merge short_description: "x" * 1001
      expect(book).to have_at_least(1).error_on :short_description

      book = BookVersion.new attributes.merge short_description: "x" * 1000
      expect(book).to be_valid
    end
  end

  describe '#cover_image_file' do
    it 'creates a new image record in the database' do
      expect do
        book = BookVersion.new attributes.merge(cover_image_file: image_file)
        book.save!
      end.to change(Image, :count).by 1
    end

    it 'creates a new image_binary record in the database' do
      expect do
        book = BookVersion.new attributes.merge(cover_image_file: image_file)
        book.save!
      end.to change(ImageBinary, :count).by 1
    end

    it 'sets the cover_image_id value of the book record' do
      book = BookVersion.new attributes.merge(cover_image_file: image_file)
      book.save!
      expect(book.cover_image_id).not_to be_nil
    end
  end

  describe '#genres' do
    let (:g1) { FactoryGirl.create(:genre) }
    let (:g2) { FactoryGirl.create(:genre) }
    let (:g3) { FactoryGirl.create(:genre) }
    let (:g4) { FactoryGirl.create(:genre) }

    it 'is a list of genres to which the book belongs' do
      book = BookVersion.new attributes
      expect(book).to have(0).genres
    end

    it 'does not accept more than 3 genres' do
      book = BookVersion.new attributes
      [g1, g2, g3, g4].each{|g| book.genres << g}
      expect(book).to have_at_least(1).error_on(:genres)
    end

    context 'when editing' do
      it 'allows the genres to be changed' do
        book_version = BookVersion.new attributes
        book_version.genres << g1
        book_version.genres << g2
        book_version.save!

        book_version.genres.delete g1
        book_version.genres.delete g2
        book_version.genres << g3
        book_version.genres << g4
        expect(book_version).to be_valid
      end
    end
  end

  describe '#sample_file' do
    it 'creates a new image record in the database' do
      expect do
        book = BookVersion.new(attributes.merge(sample_file: sample_file))
        book.save!
      end.to change(Image, :count).by(1)
    end

    it 'creates a new image_binary record in the database' do
      expect do
        book = BookVersion.new(attributes.merge(sample_file: sample_file))
        book.save!
      end.to change(ImageBinary, :count).by(1)
    end

    it 'sets the sample_id field for the book record' do
      book = BookVersion.new(attributes.merge(sample_file: sample_file))
      book.save!
      expect(book.sample_id).not_to be_nil
    end
  end

  describe '::pending' do
    it 'returns the book versions with a status of "pending"' do
      expect(BookVersion.pending.count).to eq 0
    end
  end

  describe '#new_copy' do
    let (:genre1) { FactoryGirl.create(:genre) }
    let (:genre2) { FactoryGirl.create(:genre) }
    let (:source) { FactoryGirl.create(:approved_book_version, genres: [genre1, genre2]) }
    let (:copy) { source.new_copy }
    it 'returns a new instance of BookVersion' do
      expect(copy).to be_a BookVersion
    end

    it 'sets the #title attribute on the new instance' do
      expect(copy.title).to eq source.title
    end

    it 'sets the #short_description attribute on the new instance' do
      expect(copy.short_description).to eq source.short_description
    end

    it 'sets the #long_description attribute on the new instance' do
      expect(copy.long_description).to eq source.long_description
    end

    it 'sets the #cover_image_id attribute on the new instance' do
      expect(copy.cover_image_id).to eq source.cover_image_id
    end

    it 'sets the #sample_id attribute on the new instance' do
      expect(copy.sample_id).to eq source.sample_id
    end

    it 'adds the genres to the new instance' do
      expect(copy.genres.map(&:id)).to eq [genre1.id, genre2.id]
    end

    it 'returns a non-persisted instance' do
      expect(copy).not_to be_persisted
    end
  end

  describe '#approve!' do
    let (:version) { FactoryGirl.create(:pending_book_version) }

    it 'sets the status of the book version to approved' do
      version.approve!
      expect(version).to be_approved
    end

    it 'saves the book version' do
      version.approve!
      expect(version).not_to be_changed
    end

    it 'returns true on success' do
      expect(version.approve!).to be true
    end

    context 'when another approved version exists' do
      let (:book) { FactoryGirl.create(:approved_book) }
      let!(:approved_version) { book.approved_version }
      let!(:pending_version) { FactoryGirl.create(:pending_book_version, book: book) }
      it 'sets the status of the existing approved version to "superseded"' do
        pending_version.approve!
        expect(approved_version).to be_superseded
      end
    end
  end

  describe '#reject!' do
    let (:version) { FactoryGirl.create(:pending_book_version) }

    it 'sets the status of the book version to rejected' do
      version.reject!
      expect(version).to be_rejected
    end

    it 'saves the book version' do
       version.reject!
       expect(version).not_to be_changed
    end

    it 'return strue on success' do
      expect(version.reject!).to be true
    end
  end

  describe '#sample_file' do
    it 'must be a PDF' do
      version = BookVersion.new(attributes.merge(sample_file: image_file))
      expect(version).to have_at_least(1).error_on(:sample_file)
    end
  end

  describe '#cover_image_file' do
    it 'must be an image file' do
      version = BookVersion.new(attributes.merge(cover_image_file: sample_file))
      expect(version).to have_at_least(1).error_on(:cover_image_file)
    end
  end
end
