require 'rails_helper'

RSpec.describe Author, type: :model do
  let (:attributes) do
    {
      first_name: 'John',
      last_name: 'Doe',
      phone_number: '2145550000',
      contactable: true,
      username: 'jdoe',
      email: 'john@doe.com',
      password: 'please01',
      password_confirmation: 'please01'
    }
  end

  it 'is creatable with valid attributes' do
    author = Author.new(attributes)
    expect(author).to be_valid
  end

  describe '#email' do
    it 'is required' do
      author = Author.new(attributes.except(:email))
      expect(author).to have_at_least(1).error_on :email
    end

    it 'must be a valid email address' do
      author = Author.new(attributes.merge(email: 'notavalidemail'))
      expect(author).to have_at_least(1).error_on :email
    end

    it 'must be unique' do
      a1 = Author.create!(attributes)
      a2 = Author.new(attributes)
      expect(a2).to have_at_least(1).error_on :email
    end
  end

  describe '#password' do
    it 'is required' do
      author = Author.new(attributes.except(:password))
      expect(author).to have_at_least(1).error_on :password
    end
  end

  describe '#password_confirmation' do
    it 'must match #password' do
      author = Author.new(attributes.merge(password_confirmation: 'notamatch'))
      expect(author).to have_at_least(1).error_on :password_confirmation
    end
  end

  describe '#first_name' do
    it 'is required' do
      author = Author.new attributes.except(:first_name)
      expect(author).to have_at_least(1).error_on :first_name
    end
  end

  describe '#last_name' do
    it 'is required' do
      author = Author.new attributes.except(:last_name)
      expect(author).to have_at_least(1).error_on :last_name
    end
  end

  describe '#contactable' do
    it 'defaults to false' do
      author = Author.new attributes.except(:contactable)
      expect(author).not_to be_contactable
    end
  end

  describe '#username' do
    it 'is required' do
      author = Author.new attributes.except(:username)
      expect(author).to have_at_least(1).error_on :username
    end

    it 'must be unique' do
      a1 = Author.create! attributes
      a2 = Author.new attributes
      expect(a2).to have_at_least(1).error_on :username
    end
  end
end
