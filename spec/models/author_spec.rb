require 'rails_helper'

RSpec.describe Author, type: :model do
  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe'
    }
  end

  it 'can be created from valid attributes' do
    author = Author.new attributes
    expect(author).to be_valid
  end

  describe '#first_name' do
    it 'is required' do
      author = Author.new attributes.except(:first_name)
      expect(author).to have(1).error_on :first_name
    end

    it 'cannot be more than 100 characters' do
      author = Author.new attributes.merge(first_name: 'x' * 101)
      expect(author).to have(1).error_on :first_name
    end

    it 'is unique for a given last name' do
      a1 = Author.create! attributes
      a2 = Author.new attributes
      expect(a2).to have(1).error_on :first_name
    end

    it 'can be duplicated if the last name is different' do
      a1 = Author.create! attributes
      a2 = Author.new attributes.merge(last_name: 'Dickens')
      expect(a2).to be_valid
    end
  end

  describe '#last_name' do
    it 'is required' do
      author = Author.new attributes.except(:last_name)
      expect(author).to have(1).error_on :last_name
    end

    it 'cannot be more than 100 characters' do
      author = Author.new attributes.merge(last_name: 'x' * 101)
      expect(author).to have(1).error_on :last_name
    end
  end

  describe '#bio' do
    it 'is a reference to the author\'s bio' do
      author = Author.new attributes
      expect(author.bio).to be_nil
    end
  end

  describe '#books' do
    it 'is a list of books written by the author' do
      author = Author.new attributes
      expect(author).to have(0).books
    end
  end

  describe '::by_name' do
    let!(:a1) do
      FactoryGirl.create :author, last_name: 'Smith',
                                  first_name: 'Steve'
    end
    let!(:a2) do
      FactoryGirl.create :author, last_name: 'Smith',
                                  first_name: 'Andrew'
    end
    let!(:a3) do
      FactoryGirl.create :author, last_name: 'Anderson',
                                  first_name: 'Aaron'
    end
    it 'lists authors by last name, the first name alphabeticaly order' do
      expect(Author.by_name.map(&:full_name)).to eq [
        'Aaron Anderson',
        'Andrew Smith',
        'Steve Smith'
      ]
    end
  end
end
