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

  shared_context :various_states do
    let!(:pledged1) { FactoryGirl.create(:pledged_contribution) }
    let!(:pledged2) { FactoryGirl.create(:pledged_contribution) }
    let!(:collected1) { FactoryGirl.create(:collected_contribution) }
    let!(:collected2) { FactoryGirl.create(:collected_contribution) }
    let!(:cancelled1) { FactoryGirl.create(:cancelled_contribution) }
    let!(:cancelled2) { FactoryGirl.create(:cancelled_contribution) }
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

  #context 'for a pledged contribution' do
  #  let (:payment_id) { '6CR34526N64144512' }
  #  let (:amount) { 123 }
  #  let (:contribution) { FactoryGirl.create(:contribution, amount: amount) }
  #  let!(:payment) do
  #    FactoryGirl.create(:approved_payment, contribution: contribution,
  #                                          payment_id: payment_id)
  #  end

  #  describe '#collect' do
  #    let (:response) { payment_capture_response }

  #    it 'calls the payment provider to process the payment' do
  #      expect(PAYMENT_PROVIDER).to receive(:create).
  #        with(payment_id, amount).
  #        and_return(response)
  #      contribution.collect
  #    end

  #    context 'on success' do
  #      before(:each) do
  #        expect(PAYMENT_PROVIDER).to receive(:create).
  #          with(authorization_id, amount).
  #          and_return(response)
  #      end
  #      it 'updates the state to "collected"' do
  #        expect do
  #          contribution.collect
  #        end.to change(contribution, :state).from('pledged').to('collected')
  #      end
  #    end

  #    context 'on failure' do
  #      let (:response) { payment_capture_response(state: :failed) }
  #      before(:each) do
  #        expect(PAYMENT_PROVIDER).to receive(:capture).
  #          with(authorization_id, amount).
  #          and_return(response)
  #      end

  #      it 'does not change the state of the contribution' do
  #        expect do
  #          contribution.collect
  #        end.not_to change(contribution, :state)
  #      end
  #    end

  #    context 'on error' do
  #      before(:each) do
  #        expect(PAYMENT_PROVIDER).to receive(:capture).
  #          with(authorization_id, amount).
  #          and_raise('Something bad happened')
  #      end
  #      it 'does not change the state of the contribution' do
  #        expect do
  #          contribution.collect
  #        end.not_to change(contribution, :state)
  #      end
  #      it 'writes an error to the log' do
  #        expect(Rails.logger).to receive(:error).with(/Unable to capture the payment/)
  #        contribution.collect
  #      end
  #    end
  #  end

  #  describe '#cancel' do
  #    it 'calls the payment provider to refund the payment' do
  #      expect(PAYMENT_PROVIDER).to receive(:refund).
  #        with(authorization_id).
  #        and_return(authorization_void_response)
  #      contribution.cancel
  #    end

  #    context 'on success' do
  #      before(:each) do
  #        expect(PAYMENT_PROVIDER).to receive(:void).
  #          with(authorization_id).
  #          and_return(authorization_void_response)
  #      end

  #      it 'updates the contribution state to "cancelled"' do
  #        expect do
  #          contribution.cancel
  #        end.to change(contribution, :state).from('pledged').to('cancelled')
  #      end
  #    end

  #    context 'on failure' do
  #      before(:each) do
  #        expect(PAYMENT_PROVIDER).to receive(:void).
  #          with(authorization_id).
  #          and_return(authorization_void_response(state: :expired))
  #      end

  #      it 'does not update the contribution state' do
  #        expect do
  #          contribution.cancel
  #        end.not_to change(contribution, :state)
  #      end
  #    end

  #    context 'on error' do
  #      before(:each) do
  #        expect(PAYMENT_PROVIDER).to receive(:void).
  #          with(authorization_id).
  #          and_raise('Something bad happened')
  #      end

  #      it 'does not change the state of the contribution' do
  #        expect do
  #          contribution.cancel
  #        end.not_to change(contribution, :state)
  #      end

  #      it 'writes an error to the log' do
  #        expect(Rails.logger).to receive(:error).with(/Unable to void the payment/)
  #        contribution.cancel
  #      end
  #    end
  #  end
  #end

  context 'for a collected contribution' do
    let (:contribution) { FactoryGirl.create(:collected_contribution, amount: 101) }
    let (:payment) { contribution.payments.first }

    describe '#collect' do
      it 'returns false' do
        expect(contribution.collect).to be false
      end

      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:create)
        contribution.collect
      end

      it 'does not change the state of the contribution' do
        expect do
          contribution.collect
        end.not_to change(contribution, :state)
      end
    end

    describe '#cancel' do
      it 'calls the payment provider to refund the payment' do
        expect(PAYMENT_PROVIDER).to receive(:refund).
          with(payment.sale_id, 101).
          and_return(payment_refund_response)
        contribution.cancel
      end

      context 'on success' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:refund).
            with(payment.sale_id, 101).
            and_return(payment_refund_response)
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
          expect(PAYMENT_PROVIDER).to receive(:refund).
            with(payment.sale_id, anything).
            and_return(payment_refund_response(state: 'failed'))
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

      context 'on error' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:refund).
            with(payment.sale_id, anything).
            and_raise('Induced error')
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
  end

  context 'for a cancelled contribution' do
    let (:contribution) { FactoryGirl.create(:cancelled_contribution) }

    describe '#collect' do
      it 'returns false' do
        expect(contribution.collect).to be false
      end

      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:create)
        contribution.collect
      end

      it 'does not change the state of the contribution' do
        expect do
          contribution.collect
        end.not_to change(contribution, :state)
      end
    end

    describe '#cancel' do
      it 'returns false' do
        expect(contribution.cancel).to be false
      end

      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:refund)
        contribution.cancel
      end

      it 'does not change the state of the contribution' do
        expect do
          contribution.cancel
        end.not_to change(contribution, :state)
      end
    end
  end
end
