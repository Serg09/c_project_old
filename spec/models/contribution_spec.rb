require 'rails_helper'

RSpec.describe Contribution, type: :model do
  let (:campaign) { FactoryGirl.create(:campaign) }
  let (:reward) { FactoryGirl.create(:reward, campaign: campaign) }
  let (:attributes) do
    {
      email: 'john@doe.com',
      amount: 100.00,
      campaign_id: campaign.id,
      ip_address: '123.456.789.012',
      user_agent: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.87 Safari/537.36'
    }
  end

  it 'can be created from valid attributes' do
    contribution = Contribution.new attributes
    expect(contribution).to be_valid
  end

  describe '#campaign_id' do
    it 'is required' do
      contribution = Contribution.new attributes.except(:campaign_id)
      expect(contribution).to have_at_least(1).error_on :campaign_id
    end
  end

  describe '#campaign' do
    it 'is a reference to the campaign to which the contribution belongs' do
      contribution = Contribution.new attributes
      expect(contribution.campaign).not_to be_nil
    end
  end

  describe '#email' do
    it 'is required' do
      contribution = Contribution.new attributes.except(:email)
      expect(contribution).to have_at_least(1).error_on :email
    end

    it 'must be a valid email' do
      contribution = Contribution.new attributes.merge(email: 'notavalidemail')
      expect(contribution).to have_at_least(1).error_on :email
    end
  end

  describe '#amount' do
    it 'is required' do
      contribution = Contribution.new attributes.except(:amount)
      expect(contribution).to have_at_least(1).error_on :amount
    end

    it 'must be greater than zero' do
      contribution = Contribution.new attributes.merge(amount: 0)
      expect(contribution).to have_at_least(1).error_on :amount
    end
  end

  describe '#ip_address' do
    it 'is required' do
      contribution = Contribution.new attributes.except(:ip_address)
      expect(contribution).to have_at_least(1).error_on :ip_address
    end

    it 'must be a valid IP address' do
      contribution = Contribution.new attributes.merge(ip_address: 'notavalidipaddress')
      expect(contribution).to have_at_least(1).error_on :ip_address
    end
  end

  describe '#user_agent' do
    it 'is required' do
      contribution = Contribution.new attributes.except(:user_agent)
      expect(contribution).to have_at_least(1).error_on :user_agent
    end
  end

  describe '#fulfillment' do
    let (:contribution) { FactoryGirl.create(:contribution, campaign: reward.campaign) }
    let!(:fulfillment) { FactoryGirl.create(:electronic_fulfillment, contribution: contribution, reward: reward) }

    it 'contains information about the selected reward' do
      expect(contribution.fulfillment).to eq fulfillment
    end
  end

  describe '#payment_id' do
    let (:payment) { FactoryGirl.create(:payment) }

    it 'associates the specified payment with the contribution on create' do
      contribution = Contribution.create! attributes.merge(payment_id: payment.id)
      expect(contribution.payments).to include payment
    end
  end

  shared_context :various_states do
    let!(:incipient1) { FactoryGirl.create(:incipient_contribution) }
    let!(:incipient2) { FactoryGirl.create(:incipient_contribution) }
    let!(:pledged1) { FactoryGirl.create(:pledged_contribution) }
    let!(:pledged2) { FactoryGirl.create(:pledged_contribution) }
    let!(:collected1) { FactoryGirl.create(:collected_contribution) }
    let!(:collected2) { FactoryGirl.create(:collected_contribution) }
    let!(:cancelled1) { FactoryGirl.create(:cancelled_contribution) }
    let!(:cancelled2) { FactoryGirl.create(:cancelled_contribution) }
  end

  describe '::incipient' do
    include_context :various_states
    it 'returns the contributions that have a state of "incipient"' do
      expect(Contribution.incipient.map(&:id)).to eq [incipient1.id, incipient2.id]
    end
  end

  describe '::pledged' do
    include_context :various_states
    it 'returns the contributions that have a state of "pledged"' do
      expect(Contribution.pledged.map(&:id)).to eq [pledged1.id, pledged2.id]
    end
  end

  describe '::collected' do
    include_context :various_states
    it 'returns the contributions that have a state of "collected"' do
      expect(Contribution.collected.map(&:id)).to eq [collected1.id, collected2.id]
    end
  end

  describe '::cancelled' do
    include_context :various_states
    it 'returns the contributions that have a state of "cancelled"' do
      expect(Contribution.cancelled.map(&:id)).to eq [cancelled1.id, cancelled2.id]
    end
  end

  shared_examples 'a non-collectable contribution' do
    let!(:payment) { contribution.payments.first }

    it 'returns false' do
      expect(contribution.collect).to be false
    end

    it 'does not execute the payment' do
      expect(payment).not_to receive(:execute!)
      contribution.collect
    end

    it 'does not change the state of the contribution' do
      expect do
        contribution.collect
      end.not_to change(contribution, :state)
    end
  end

  shared_examples 'a cancellable contribution' do
    it 'refunds the payment' do
      expect_any_instance_of(Payment).to receive(:refund!).and_return true
      contribution.cancel
    end

    context 'on success' do
      before(:each) do
        expect_any_instance_of(Payment).to receive(:refund!).and_return true
      end

      it 'returns true' do
        expect(contribution.cancel).to be true
      end

      it 'changes the state of the contribution to cancelled' do
        expect do
          contribution.cancel
        end.to change(contribution, :state).from('collected').to('cancelled')
      end
    end

    context 'on failure' do
      before(:each) do
        expect_any_instance_of(Payment).to receive(:refund!).and_return false
      end

      it 'returns false' do
        expect(contribution.cancel).to be false
      end

      it 'does not change the state of the contribution' do
        expect do
          contribution.cancel
        end.not_to change(contribution, :state)
      end
    end
  end

  shared_examples 'a non-cancellable contribution' do
    let!(:payment) { contribution.payments.first }

    it 'returns false' do
      expect(contribution.cancel).to be false
    end

    it 'does not execute the payment' do
      expect(payment).not_to receive(:execute)
      contribution.cancel
    end

    it 'does not change the state of the contribution' do
      expect do
        contribution.cancel
      end.not_to change(contribution, :state)
    end
  end

  context 'when incipient' do
    let (:contribution) { FactoryGirl.create(:incipient_contribution) }
    let!(:payment) do
      payment = FactoryGirl.create(:pending_payment)
      contribution.payments << payment
      payment
    end

    describe '#collect' do
      it 'calls :execute on the payment' do
        expect(payment).to receive(:execute!).and_return true
        contribution.collect!
      end

      context 'on success' do
        before(:each) do
          expect(payment).to receive(:execute!).and_return true
        end

        it 'returns true' do
          expect(contribution.collect!).to be true
        end

        it 'changes the state to "collected"' do
          expect do
            contribution.collect!
          end.to change(contribution, :state).to 'collected'
        end
      end

      context 'on failure' do
        before(:each) do
          expect(payment).to receive(:execute!).and_return false
        end

        it 'returns false' do
          expect(contribution.collect!).to be false
        end

        it 'does not change the state' do
          expect do
            contribution.collect!
          end.not_to change(contribution, :state)
        end
      end
    end
  end

  context 'when collected' do
    describe '#collect' do
      it_behaves_like 'a non-collectable contribution' do
        let (:contribution) { FactoryGirl.create(:collected_contribution, amount: 101) }
      end
    end

    describe '#cancel' do
      it_behaves_like 'a cancellable contribution' do
        let (:contribution) { FactoryGirl.create(:collected_contribution, amount: 101) }
      end
    end
  end

  context 'when cancelled' do

    describe '#collect' do
      it_behaves_like 'a non-collectable contribution' do
        let (:contribution) { FactoryGirl.create(:cancelled_contribution) }
        let!(:payment) do
          FactoryGirl.create(:refunded_payment, contribution: contribution)
        end
      end
    end

    describe '#cancel' do
      it_behaves_like 'a non-cancellable contribution' do
        let (:contribution) { FactoryGirl.create(:cancelled_contribution) }
        let!(:payment) do
          FactoryGirl.create(:refunded_payment, contribution: contribution)
        end
      end
    end
  end
end
