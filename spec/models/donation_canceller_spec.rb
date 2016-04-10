require 'rails_helper'

describe DonationCanceller do
  let (:campaign) { FactoryGirl.create(:cancelling_campaign) }
  let (:donation1) { FactoryGirl.create(:donation, campaign: campaign) }
  let (:donation2) { FactoryGirl.create(:donation, campaign: campaign) }
  let!(:payment1) { FactoryGirl.create(:payment, donation: donation1) }
  let!(:payment2) { FactoryGirl.create(:payment, donation: donation2) }
  let (:success_response) { payment_capture_response }
  let (:failure_response) { payment_capture_response(state: :failed) }

  describe '::perform' do
    context 'when all donations are cancelled successfully' do
      before(:each) do
        allow(PAYMENT_PROVIDER).to receive(:void).and_return(authorization_void_response)
      end

      it 'updates the campaign state to "cancelled"' do
        expect do
          DonationCanceller.perform campaign.id
          campaign.reload
        end.to change(campaign, :state).from('cancelling').to('cancelled')
      end
    end

    context 'when any donation cannot be cancelled' do
      before(:each) do
        allow(PAYMENT_PROVIDER).to receive(:void).and_return(authorization_void_response)
        expect(PAYMENT_PROVIDER).to receive(:void).
          with(payment2.authorization_id).
          and_raise('Induced error')
      end
      context 'before the maximum attempt count has been reached' do
        it 're-enqueues a cancellation job' do
          expect(Resque).to receive(:enqueue_in).with(2.hours, DonationCanceller, campaign.id, 2)
          DonationCanceller.perform campaign.id
        end

        it 'does not change the state of the campaign' do
          expect do
            DonationCanceller.perform campaign.id
            campaign.reload
          end.not_to change(campaign, :state)
        end
      end

      context 'after the maximum attempt count has been reached' do
        it 'does not re-enqueue a cancellation job' do
          expect(Resque).not_to receive(:enqueue_in)
          DonationCanceller.perform campaign.id, 3
        end

        it 'changes the state of the campaign to cancelled' do
          expect do
            DonationCanceller.perform campaign.id, 3
            campaign.reload
          end.to change(campaign, :state).from('cancelling').to('cancelled')
        end
      end
    end
  end
end
