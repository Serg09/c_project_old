require 'rails_helper'

describe DonationCanceller do
  let (:campaign) { FactoryGirl.create(:collecting_campaign) }
  let (:donation1) { FactoryGirl.create(:donation, campaign: campaign) }
  let (:donation2) { FactoryGirl.create(:donation, campaign: campaign) }
  let!(:payment1) { FactoryGirl.create(:payment, donation: donation1) }
  let!(:payment2) { FactoryGirl.create(:payment, donation: donation2) }
  let (:success_response) { payment_capture_response }
  let (:failure_response) { payment_capture_response(state: :failed) }

  describe '::perform' do
    it 'calls #void on each donation for the campaign' do
      campaign.donations.each{|d| expect(d).to receive(:void)}
      DonationCanceller.perform(campaign.id)
    end

    context 'when all donations return true' do
      it 'updates the campaign state to "cancelled"'
    end

    context 'when any donation returns false' do
      context 'before the maximum attempt count has been reached' do
        it 're-enqueues a cancellation job'
        it 'does not change the state of the campaign'
      end

      context 'after the maximum attempt count has been reached' do
        it 'does not re-enqueue a cancellation job'
        it 'changes the state of the campaign to cancelled'
      end
    end
  end
end
