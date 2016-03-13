require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:donation) { FactoryGirl.create(:donation) }
  let (:attributes) do
    {
      donation_id: donation.id,
      external_id: 'PAY-17S8410768582940NKEE66EQ',
      state: 'approved',
      content: File.read(Rails.root.join('spec', 'fixtures', 'files', 'payment.json'))
    }
  end

  it 'can be created from valid attributes' do
    payment = Payment.new attributes
    expect(payment).to be_valid
  end

  describe '#donation_id' do
    it 'is required' do
      payment = Payment.new attributes.except(:donation_id)
      expect(payment).to have_at_least(1).error_on :donation_id
    end
  end

  describe '#external_id' do
    it 'is required' do
      payment = Payment.new attributes.except(:external_id)
      expect(payment).to have_at_least(1).error_on :external_id
    end
  end

  describe '#state' do
    it 'is required' do
      payment = Payment.new attributes.except(:state)
      expect(payment).to have_at_least(1).error_on :state
    end
  end

  describe '#content' do
    it 'is required' do
      payment = Payment.new attributes.except(:content)
      expect(payment).to have_at_least(1).error_on :content
    end
  end
end
