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

  describe '::find_working_version' do
    context 'when an approved version and a pending version are present' do
      let (:author) { book.author }
      let (:book) { approved_book_version.book }
      let (:approved_book_version) { FactoryGirl.create(:approved_book_version) }
      let (:pending_book_version) { FactoryGirl.create(:pending_book_version, book: book) }
      let (:other_author) { FactoryGirl.create(:approved_author) }

      context 'with no author' do
        it 'returns the approved version' do
          working_version = Book.find_working_version(nil, book.id)
          expect(working_version).to be_approved
        end
      end

      context 'with an author that does not own the book' do
        it 'returns the approved version' do
          working_version = Book.find_working_version(other_author, book.id)
          expect(working_version).to be_approved
        end
      end

      context 'with the author that owns the book' do
        it 'returns the pending version' do
          working_version = Book.find_working_version(author, book.id)
          expect(working_version).to be_pending
        end
      end
    end
  end
end
