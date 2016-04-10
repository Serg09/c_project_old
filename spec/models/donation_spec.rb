require 'rails_helper'

RSpec.describe Donation, type: :model do
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
    donation = Donation.new attributes
    expect(donation).to be_valid
  end

  describe '#campaign_id' do
    it 'is required' do
      donation = Donation.new attributes.except(:campaign_id)
      expect(donation).to have_at_least(1).error_on :campaign_id
    end
  end

  describe '#campaign' do
    it 'is a reference to the campaign to which the donation belongs' do
      donation = Donation.new attributes
      expect(donation.campaign).not_to be_nil
    end
  end

  describe '#email' do
    it 'is required' do
      donation = Donation.new attributes.except(:email)
      expect(donation).to have_at_least(1).error_on :email
    end

    it 'must be a valid email' do
      donation = Donation.new attributes.merge(email: 'notavalidemail')
      expect(donation).to have_at_least(1).error_on :email
    end
  end

  describe '#amount' do
    it 'is required' do
      donation = Donation.new attributes.except(:amount)
      expect(donation).to have_at_least(1).error_on :amount
    end

    it 'must be greater than zero' do
      donation = Donation.new attributes.merge(amount: 0)
      expect(donation).to have_at_least(1).error_on :amount
    end
  end

  describe '#ip_address' do
    it 'is required' do
      donation = Donation.new attributes.except(:ip_address)
      expect(donation).to have_at_least(1).error_on :ip_address
    end

    it 'must be a valid IP address' do
      donation = Donation.new attributes.merge(ip_address: 'notavalidipaddress')
      expect(donation).to have_at_least(1).error_on :ip_address
    end
  end

  describe '#user_agent' do
    it 'is required' do
      donation = Donation.new attributes.except(:user_agent)
      expect(donation).to have_at_least(1).error_on :user_agent
    end
  end

  describe '#reward' do
    let (:other_reward) { FactoryGirl.create(:reward) }

    it 'is a reference to the reward selected for the donation' do
      donation = Donation.new attributes.merge(reward_id: reward.id)
      expect(donation.reward.id).to eq reward.id
    end

    it 'must reference the same campaign as the donation' do
      donation = Donation.new attributes.merge(reward_id: other_reward.id)
      expect(donation).to have_at_least(1).error_on :reward_id
    end
  end

  shared_context :various_states do
    let!(:pledged1) { FactoryGirl.create(:pledged_donation) }
    let!(:pledged2) { FactoryGirl.create(:pledged_donation) }
    let!(:collected1) { FactoryGirl.create(:collected_donation) }
    let!(:collected2) { FactoryGirl.create(:collected_donation) }
    let!(:cancelled1) { FactoryGirl.create(:cancelled_donation) }
    let!(:cancelled2) { FactoryGirl.create(:cancelled_donation) }
  end

  describe '::pledged' do
    include_context :various_states
    it 'returns the donations that have a state of "pledged"' do
      expect(Donation.pledged.map(&:id)).to eq [pledged1.id, pledged2.id]
    end
  end

  describe '::collected' do
    include_context :various_states
    it 'returns the donations that have a state of "collected"' do
      expect(Donation.collected.map(&:id)).to eq [collected1.id, collected2.id]
    end
  end

  describe '::cancelled' do
    include_context :various_states
    it 'returns the donations that have a state of "cancelled"' do
      expect(Donation.cancelled.map(&:id)).to eq [cancelled1.id, cancelled2.id]
    end
  end

  context 'for a pledged donation' do
    let (:authorization_id) { '6CR34526N64144512' }
    let (:amount) { 123 }
    let (:donation) { FactoryGirl.create(:donation, amount: amount) }
    let!(:payment) do
      FactoryGirl.create(:approved_payment, donation: donation,
                                            authorization_id: authorization_id)
    end

    describe '#collect' do
      let (:response) { payment_capture_response }

      it 'calls the payment provider to capture the payment' do
        expect(PAYMENT_PROVIDER).to receive(:capture).
          with(authorization_id, amount).
          and_return(response)
        donation.collect
      end

      context 'on success' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:capture).
            with(authorization_id, amount).
            and_return(response)
        end
        it 'updates the state to "collected"' do
          expect do
            donation.collect
          end.to change(donation, :state).from('pledged').to('collected')
        end
      end

      context 'on failure' do
        let (:response) { payment_capture_response(state: :failed) }
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:capture).
            with(authorization_id, amount).
            and_return(response)
        end

        it 'does not change the state of the donation' do
          expect do
            donation.collect
          end.not_to change(donation, :state)
        end
      end

      context 'on error' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:capture).
            with(authorization_id, amount).
            and_raise('Something bad happened')
        end
        it 'does not change the state of the donation' do
          expect do
            donation.collect
          end.not_to change(donation, :state)
        end
        it 'writes an error to the log' do
          expect(Rails.logger).to receive(:error).with(/Unable to capture the payment/)
          donation.collect
        end
      end
    end

    describe '#cancel' do
      it 'calls the payment provider to void the authorization' do
        expect(PAYMENT_PROVIDER).to receive(:void).
          with(authorization_id).
          and_return(authorization_void_response)
        donation.cancel
      end

      context 'on success' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:void).
            with(authorization_id).
            and_return(authorization_void_response)
        end

        it 'updates the donation state to "cancelled"' do
          expect do
            donation.cancel
          end.to change(donation, :state).from('pledged').to('cancelled')
        end
      end

      context 'on failure' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:void).
            with(authorization_id).
            and_return(authorization_void_response(state: :expired))
        end

        it 'does not update the donation state' do
          expect do
            donation.cancel
          end.not_to change(donation, :state)
        end
      end

      context 'on error' do
        before(:each) do
          expect(PAYMENT_PROVIDER).to receive(:void).
            with(authorization_id).
            and_raise('Something bad happened')
        end

        it 'does not change the state of the donation' do
          expect do
            donation.cancel
          end.not_to change(donation, :state)
        end

        it 'writes an error to the log' do
          expect(Rails.logger).to receive(:error).with(/Unable to void the payment/)
          donation.cancel
        end
      end
    end
  end

  context 'for a collected donation' do
    let (:donation) { FactoryGirl.create(:collected_donation) }

    describe '#collect' do
      it 'returns false' do
        expect(donation.collect).to be false
      end

      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:capture)
        donation.collect
      end

      it 'does not change the state of the donation' do
        expect do
          donation.collect
        end.not_to change(donation, :state)
      end
    end

    describe '#cancel' do
      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:void)
        donation.collect
      end

      it 'returns false' do
        expect(donation.cancel).to be false
      end

      it 'does not change the state of the donation' do
        expect do
          donation.cancel
        end.not_to change(donation, :state)
      end
    end
  end

  context 'for a cancelled donation' do
    let (:donation) { FactoryGirl.create(:cancelled_donation) }

    describe '#collect' do
      it 'returns false' do
        expect(donation.collect).to be false
      end

      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:capture)
        donation.collect
      end

      it 'does not change the state of the donation' do
        expect do
          donation.collect
        end.not_to change(donation, :state)
      end
    end

    describe '#cancel' do
      it 'returns false' do
        expect(donation.cancel).to be false
      end

      it 'does not call the payment provider' do
        expect(PAYMENT_PROVIDER).not_to receive(:void)
        donation.cancel
      end

      it 'does not change the state of the donation' do
        expect do
          donation.cancel
        end.not_to change(donation, :state)
      end
    end
  end
end
