require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  it 'can be created from valid attributes'

  describe '#payment_id' do
    it 'is required'
  end

  describe '#payment' do
    it 'is a reference to the payment to which the transaction beongs'
  end

  describe '#intent' do
    it 'is required'
    it 'can be "sale"'
    it 'can be "authorize"'
    it 'cannot be anything other than "sale" or "authorize"'
  end

  describe '#state' do
    it 'is required'
    it 'can be "created"'
    it 'can be "approved"'
    it 'can be "failed"'
    it 'can be "canceled"'
    it 'can be "expired"'
    it 'can be "pending"'
    it 'cannot be anything other than "created", "approved", "failed", "canceled", "expired", or "pending"'
  end

  describe '#content' do
    it 'is required'
  end
end
