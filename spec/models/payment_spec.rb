require 'rails_helper'

RSpec.describe Payment, type: :model do
  let (:contribution) { FactoryGirl.create(:contribution) }
  let (:attributes) do
    {
      contribution_id: contribution.id,
      external_id: 'PAY-17S8410768582940NKEE66EQ',
      state: 'approved',
    }
  end

  it 'can be created from valid attributes' do
    payment = Payment.new attributes
    expect(payment).to be_valid
  end

  describe '#contribution_id' do
    it 'is required' do
      payment = Payment.new attributes.except(:contribution_id)
      expect(payment).to have_at_least(1).error_on :contribution_id
    end
  end

  describe '#contribution' do
    it 'is a reference to the contribution to which the payment belongs' do
      payment = Payment.new attributes
      expect(payment.contribution.id).to be contribution.id
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
      expect(payment.transactions.count).to eq 1
    end
  end

  describe '#sale_id' do
    let (:payment) { FactoryGirl.create(:approved_payment, sale_id: 'ABC123') }
    it 'returns the first sale ID found  in the transaction content' do
      expect(payment.sale_id).to eq 'ABC123'
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
