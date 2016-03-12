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

  describe '#new_version!' do
    let (:book) { FactoryGirl.create(:approved_book) }
    let (:attributes) do
      {
        title: 'New title',
        short_description: 'This one is short',
        long_description: 'This on is long'
      }
    end
    it 'creates a new version record' do
      book.versions # reload the versions
      expect do
        book.new_version! attributes
      end.to change(book.versions, :count).by(1)
    end

    it 'returns true for success' do
      expect(book.new_version!(attributes)).to be true
    end

    it 'sets the #pending_version property' do
      book.new_version! attributes
      expect(book.pending_version.id).to be BookVersion.last.id
    end
  end

  describe '#working_version' do
    context 'for a book that is pending' do
      it 'returns the pending version' do
        book = FactoryGirl.create(:pending_book)
        expect(book.working_version.id).to eq book.pending_version.id
      end
    end

    context 'for a book that is approved' do
      it 'returns the approved version' do
        book = FactoryGirl.create(:approved_book)
        expect(book.working_version.id).to eq book.approved_version.id
      end
    end

    context 'for an approved book with a pending edit' do
      it 'returns the pending version' do
        book = FactoryGirl.create(:approved_book)
        FactoryGirl.create(:pending_book_version, book: book)
        expect(book.working_version.id).to eq book.pending_version.id
      end
    end

    context 'for a book that is rejected' do
      it 'returns the rejected version' do
        book = FactoryGirl.create(:rejected_book)
        expect(book.working_version.id).to eq book.rejected_version.id
      end
    end

    context 'for an approved book with a rejected edit' do
      it 'returns the approved version' do
        book = FactoryGirl.create(:approved_book)
        FactoryGirl.create(:rejected_book_version, book: book)
        expect(book.working_version.id).to eq book.approved_version.id
      end
    end
  end

  describe '#campaigns' do
    it 'is a list of campaigns associated with the book' do
      book = Book.new(attributes)
      expect(book).to have(0).campaigns
    end
  end

  shared_context :campaigns do
    let (:author) { FactoryGirl.create(:approved_author) }
    let (:book) { FactoryGirl.create(:approved_book, author: author) }
    let!(:campaign) { FactoryGirl.create(:campaign, book: book, paused: false) }
  end

  context 'for an author with an approved bio' do
    include_context :campaigns
    let!(:bio) { FactoryGirl.create(:approved_bio, author: book.author) }

    describe '#active_campaign' do
      it 'is the campaign that is currently active' do
        expect(book.active_campaign.try(:id)).to eq campaign.id
      end
    end
  end

  context 'for an author without an approved bio' do
    include_context :campaigns

    describe '#active_campaign' do
      it 'is nil' do
        expect(book.active_campaign).to be_nil
      end
    end
  end
end
