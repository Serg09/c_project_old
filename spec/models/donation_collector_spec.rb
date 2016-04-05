require 'rails_helper'

describe DonationCollector do
  let (:campaign) { FactoryGirl.create(:collecting_campaign) }
  let (:donation1) { FactoryGirl.create(:donation, campaign: campaign) }
  let (:donation2) { FactoryGirl.create(:donation, campaign: campaign) }
  let!(:payment1) { FactoryGirl.create(:payment, donation: donation1) }
  let!(:payment2) { FactoryGirl.create(:payment, donation: donation2) }
  let (:success_response) { payment_capture_response }
  let (:failure_response) { payment_capture_response(state: :failed) }

  before(:each) do
    allow(PAYMENT_PROVIDER).to receive(:capture).
      and_return(success_response)
  end

  describe '::perform' do
    context 'when all donations are collected successfull' do
      it 'sends a notification email to the author' do
        expect(CampaignMailer).to receive(:collection_complete).with(campaign)
        DonationCollector.perform(campaign.id)
      end
    end

    context 'when one or more donations are not collected successfully' do
      before(:each) do
        expect(PAYMENT_PROVIDER).to receive(:capture).
          with(payment2.external_id, anything).
          and_return(failure_response)
      end

      context 'before reaching 3 attempts' do
        it 'enqueues a job to try again later' do
          expect(Resque).to receive(:enqueue_in).with(2.hours, DonationCollector, campaign.id, 2)
          DonationCollector.perform(campaign.id)
        end

        it 'does not change the state of the campaign' do
          expect do
            DonationCollector.perform(campaign.id)
            campaign.reload
          end.not_to change(campaign, :state)
        end

        it 'does not send a notification email to the author' do
          expect(CampaignMailer).not_to receive(:collection_complete)
          DonationCollector.perform(campaign.id)
        end
      end

      context 'after reaching 3 attempts' do
        it 'does not re-enqueue the job another time' do
          expect(Resque).not_to receive(:enqueue_in)
          DonationCollector.perform(campaign.id, 3)
        end

        it 'changes the campaign state to "collected"' do
          expect do
            DonationCollector.perform(campaign.id, 3)
            campaign.reload
          end.to change(campaign, :state).from('collecting').to('collected')
        end

        it 'sends a notification email to the author' do
          expect(CampaignMailer).to receive(:collection_complete).with(campaign)
          DonationCollector.perform(campaign.id, 3)
        end
      end
    end
  end
end
