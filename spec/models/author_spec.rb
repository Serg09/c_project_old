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
end
