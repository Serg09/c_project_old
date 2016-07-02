require 'rails_helper'

RSpec.describe Subscriber, type: :model do
  let (:attributes) do
    {
      first_name: 'John',
      last_name:  'Doe',
      email: 'john@doe.com'
    }
  end

  it 'can be created from valid attribute' do
    subscriber = Subscriber.new attributes
    expect(subscriber).to be_valid
  end

  describe 'first_name' do
    it 'is required' do
      subscriber = Subscriber.new attributes.except(:first_name)
      expect(subscriber).to have(1).error_on :first_name
    end

    it 'cannot be longer than 50 characters' do
      subscriber = Subscriber.new attributes.merge(first_name: 'x' * 51)
      expect(subscriber).to have(1).error_on :first_name
    end
  end

  describe 'last_name' do
    it 'is required' do
      subscriber = Subscriber.new attributes.except(:last_name)
      expect(subscriber).to have(1).error_on :last_name
    end

    it 'cannot be longer than 50 characters' do
      subscriber = Subscriber.new attributes.merge(last_name: 'x' * 51)
      expect(subscriber).to have(1).error_on :last_name
    end
  end

  describe 'email' do
    it 'is required' do
      subscriber = Subscriber.new attributes.except(:email)
      expect(subscriber).to have(1).error_on :email
    end

    it 'cannot be longer than 50 characters' do
      subscriber = Subscriber.new attributes.merge(email: "#{'x' * 241}@gmail.com")
      expect(subscriber).to have(1).error_on :email
    end

    it 'must be a valid email address' do
      subscriber = Subscriber.new attributes.merge(email: 'notavalidemailaddress')
      expect(subscriber).to have(1).error_on :email
    end

    it 'does not allow duplicates' do
      s1 = Subscriber.create! attributes
      s2 = Subscriber.new attributes.merge(email: 'John@Doe.com')

      expect(s2).not_to be_valid
      expect(s2).to have(1).error_on :email
    end
  end
end
