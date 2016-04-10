require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:donation) { FactoryGirl.create(:donation) }
  let (:attributes) do
    {
      donation_id: donation.id,
      external_id: 'PAY-17S8410768582940NKEE66EQ',
      state: 'approved',
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

  describe '#donation' do
    it 'is a reference to the donation to which the payment belongs' do
      payment = Payment.new attributes
      expect(payment.donation.id).to be donation.id
    end
  end

  describe '#external_id' do
    it 'is required' do
      payment = Payment.new attributes.except(:external_id)
      expect(payment).to have_at_least(1).error_on :external_id
    end

    it 'is unique' do
      p1 = Payment.create! attributes
      p2 = Payment.new attributes
      expect(p2).to have_at_least(1).error_on :external_id
    end
  end

  describe '#state' do
    it 'is required' do
      payment = Payment.new attributes.except(:state)
      expect(payment).to have_at_least(1).error_on :state
    end
  end

  describe '#transactions' do
    let (:payment) { FactoryGirl.create(:approved_payment) }
    it 'contains a list of transactions with the payment provider' do
      expect(payment.transactions.count).to be 1
    end
  end

  describe '#authorization_id' do
    let (:authorization_id) { 'ABC123' }
    let (:payment) { FactoryGirl.create(:approved_payment, authorization_id: authorization_id) }
    it 'returns the first authorization_id from the transactions' do
      expect(payment.authorization_id).to eq authorization_id
    end
  end

  shared_context :stateful_payments do
    let!(:approved1) { FactoryGirl.create(:approved_payment) }
    let!(:approved2) { FactoryGirl.create(:approved_payment) }
    let!(:failed1) { FactoryGirl.create(:failed_payment) }
    let!(:failed2) { FactoryGirl.create(:failed_payment) }
  end

  describe '::approved' do
    include_context :stateful_payments

    it 'returns all payments where the state is "approved"' do
      expect(Payment.approved.map(&:id)).to eq [approved1.id, approved2.id]
    end
  end

  describe '::failed' do
    include_context :stateful_payments

    it 'returns all payments where the state is "failed"' do
      expect(Payment.failed.map(&:id)).to eq [failed1.id, failed2.id]
    end
  end
end
