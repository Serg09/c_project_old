require 'rails_helper'

describe DonationCanceller do
  let (:campaign) { FactoryGirl.create(:cancelling_campaign) }
  let (:donation1) { FactoryGirl.create(:collected_donation, campaign: campaign) }
  let (:donation2) { FactoryGirl.create(:collected_donation, campaign: campaign) }
  let (:payment1) { donation1.payments.first }
  let (:payment2) { donation2.payments.first }
  let (:success_response) { payment_create_response }
  let (:failure_response) { payment_create_response(state: :failed) }

  describe '::perform' do
    context 'when all donations are cancelled successfully' do
      before(:each) do
        allow(PAYMENT_PROVIDER).to receive(:refund)
          .and_return(payment_refund_response)
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
        allow(PAYMENT_PROVIDER).to receive(:refund).
          and_return(payment_refund_response)
        expect(PAYMENT_PROVIDER).to receive(:refund).
          with(payment2.sale_id, donation2.amount).
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

    context 'for a campaign that is not in the cancelling state' do
      let (:campaign) { FactoryGirl.create(:active_campaign) }

      it 'writes a warning to the log' do
        allow(Rails.logger).to receive(:warn)
        expect(Rails.logger).to receive(:warn).with(/donations will not be cancelled/)
        DonationCanceller.perform(campaign.id)
      end

      it 'does not re-enqueue the job for reprocessing' do
        expect(Resque).not_to receive(:enqueue_in)
        DonationCanceller.perform(campaign.id)
      end
    end
  end
end
