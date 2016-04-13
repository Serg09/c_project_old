require 'rails_helper'

describe DonationCollector do
  let (:campaign) { FactoryGirl.create(:collecting_campaign) }
  let (:donation1) { FactoryGirl.create(:donation, campaign: campaign) }
  let (:donation2) { FactoryGirl.create(:donation, campaign: campaign) }
  let!(:payment1) { FactoryGirl.create(:payment, donation: donation1) }
  let!(:payment2) { FactoryGirl.create(:payment, donation: donation2) }
  let (:success_response) { payment_create_response }
  let (:failure_response) { payment_create_response(state: :failed) }

  before(:each) do
    allow(PAYMENT_PROVIDER).to receive(:create).
      and_return(success_response)
  end

  describe '::perform' do
    it 'writes an INFO entry to the log indicating the start of the process' do
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with(/Collecting donations for campaign #{campaign.id}/)
      DonationCollector.perform(campaign.id)
    end

    context 'when all donations are collected successfull' do
      it 'sends a notification email to the author' do
        expect(CampaignMailer).to receive(:collection_complete).with(campaign)
        DonationCollector.perform(campaign.id)
      end

      it 'writes an INFO entry to the log indicating completion of the process' do
        allow(Rails.logger).to receive(:info).at_least(:once)
        expect(Rails.logger).to receive(:info).with(/Completed donation collection for campaign #{campaign.id}/)
        DonationCollector.perform(campaign.id)
      end
    end

    #context 'when one or more donations are not collected successfully' do
    #  context 'before reaching 3 attempts' do
    #    it 'enqueues a job to try again later'
    #    it 'does not change the state of the campaign'
    #    it 'does not send a notification email to the author'
    #    it 'writes a WARNING entry to the log indicating the inability to complete'
    #  end

    #  context 'after reaching 3 attempts' do
    #    it 'does not re-enqueue the job another time'
    #    it 'changes the campaign state to "collected"'
    #    it 'sends a notification email to the author'
    #    it 'writes a WARNING entry to the log, indicating completion with partial success'
    #  end
    #end
  end
end
