require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  let (:payment) { FactoryGirl.create(:payment) }
  let (:response) do
    path = Rails.root.join('spec', 'fixtures', 'files', 'payment.json')
    File.read(path)
  end
  let (:attributes) do
    {
      payment_id: payment.id,
      intent: 'authorize',
      state: 'approved',
      response: response
    }
  end

  it 'can be created from valid attributes' do
    tx = PaymentTransaction.new attributes
    expect(tx).to be_valid
  end

  describe '#payment_id' do
    it 'is required' do
      tx = PaymentTransaction.new attributes.except(:payment_id)
      expect(tx).to have_at_least(1).error_on :payment_id
    end
  end

  describe '#payment' do
    it 'is a reference to the payment to which the transaction beongs' do
      tx = PaymentTransaction.new attributes
      expect(tx.payment).to eq payment
    end
  end

  describe '#intent' do
    it 'is required' do
      tx = PaymentTransaction.new attributes.except(:intent)
      expect(tx).to have_at_least(1).error_on :intent
    end

    it 'can be "sale"' do
      tx = PaymentTransaction.new attributes.merge(intent: PaymentTransaction.SALE)
      expect(tx).to be_valid
    end

    it 'can be "refund"' do
      tx = PaymentTransaction.new attributes.merge(intent: PaymentTransaction.REFUND)
      expect(tx).to be_valid
    end

    it 'cannot be anything other than "sale" or "authorize"' do
      tx = PaymentTransaction.new attributes.merge(intent: 'notarealone')
      expect(tx).to have_at_least(1).error_on :intent
    end
  end

  describe '#state' do
    it 'is required' do
      tx = PaymentTransaction.new attributes.except(:state)
      expect(tx).to have_at_least(1).error_on :state
    end
  end

  describe '#response' do
    it 'is required' do
      tx = PaymentTransaction.new attributes.except(:response)
      expect(tx).to have_at_least(1).error_on :response
    end
  end

  shared_context :various_states do
    let!(:approved1) { FactoryGirl.create(:approved_payment_transaction) }
    let!(:approved2) { FactoryGirl.create(:approved_payment_transaction) }
    let!(:captured1) { FactoryGirl.create(:captured_payment_transaction) }
    let!(:captured2) { FactoryGirl.create(:captured_payment_transaction) }
    let!(:voided1) { FactoryGirl.create(:voided_payment_transaction) }
    let!(:voided2) { FactoryGirl.create(:voided_payment_transaction) }
  end

  describe '::approved' do
    include_context :various_states
    it 'returns the transaction with a state of "approved"' do
      expect(PaymentTransaction.approved.map(&:id)).to eq [approved1.id, approved2.id]
    end
  end

  describe '::voided' do
    include_context :various_states
    it 'returns the transaction with a state of "voided"' do
      expect(PaymentTransaction.voided.map(&:id)).to eq [voided1.id, voided2.id]
    end
  end

  describe '::captured' do
    include_context :various_states
    it 'returns the transaction with a state of "captured"' do
      expect(PaymentTransaction.captured.map(&:id)).to eq [captured1.id, captured2.id]
    end
  end
end
