require 'rails_helper'

RSpec.describe PaymentTransaction, type: :model do
  let (:payment) { FactoryGirl.create(:payment) }
  let (:response) { payment_create_response }
  let (:attributes) do
    {
      payment_id: payment.id,
      intent: 'sale',
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
    let!(:pending1) { FactoryGirl.create(:pending_payment_transaction) }
    let!(:pending2) { FactoryGirl.create(:pending_payment_transaction) }
    let!(:completed1) { FactoryGirl.create(:completed_payment_transaction) }
    let!(:completed2) { FactoryGirl.create(:completed_payment_transaction) }
    let!(:failed1) { FactoryGirl.create(:failed_payment_transaction) }
    let!(:failed2) { FactoryGirl.create(:failed_payment_transaction) }
  end

  describe '::pending' do
    include_context :various_states
    it 'returns the transaction with a state of "pending"' do
      expect(PaymentTransaction.pending.map(&:id)).to eq [pending1.id, pending2.id]
    end
  end

  describe '::completed' do
    include_context :various_states
    it 'returns the transaction with a state of "completed"' do
      grouped = PaymentTransaction.completed.group_by(&:state)
      expect(grouped).to have(1).item
      expect(grouped).to have_key('completed')
    end
  end

  describe '::failed' do
    include_context :various_states
    it 'returns the transaction with a state of "failed"' do
      expect(PaymentTransaction.failed.map(&:id)).to eq [failed1.id, failed2.id]
    end
  end
end
