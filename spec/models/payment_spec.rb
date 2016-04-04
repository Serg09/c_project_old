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

  describe '#content' do
    it 'is required' do
      payment = Payment.new attributes.except(:content)
      expect(payment).to have_at_least(1).error_on :content
    end
  end

  shared_context :stateful_payments do
    let!(:approved1) { FactoryGirl.create(:approved_payment) }
    let!(:approved2) { FactoryGirl.create(:approved_payment) }
    let!(:failed1) { FactoryGirl.create(:failed_payment) }
    let!(:failed2) { FactoryGirl.create(:failed_payment) }
  end

  context 'for a payment that has been captured successfully' do
    let (:payment) { FactoryGirl.create(:completed_payment) }

    describe '#paid?' do
      it 'is true' do
        expect(payment).to be_paid
      end
    end
  end

  context 'for a payment that has not been captured successfully' do
    let (:payment) { FactoryGirl.create(:payment) }

    describe '#paid?' do
      it 'is false' do
        expect(payment).not_to be_paid
      end
    end
  end

  describe '#update_content' do
    let!(:payment) { FactoryGirl.create(:payment) }
    let!(:new_content) do
      hash = JSON.parse(payment.content)
      hash['state'] = 'completed'
      hash.to_json
    end

    it 'updates the content attribute with the specified value' do
      expect do
        payment.update_content new_content
        payment.reload
      end.to change(payment, :content).to new_content
    end

    it 'updates the state  with the appropriate value for the content' do
      expect do
        payment.update_content new_content
        payment.reload
      end.to change(payment, :state).from('approved').to('completed')
    end
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
