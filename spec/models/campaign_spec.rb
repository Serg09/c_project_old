require 'rails_helper'

RSpec.describe Campaign, type: :model do
  let (:book) { FactoryGirl.create(:approved_book) }

  let (:attributes) do
    {
      book_id: book.id,
      target_date: Date.new(2016, 3, 31),
      target_amount: 5_000
    }
  end

  before(:each) { Timecop.freeze(DateTime.parse('2016-03-02 12:00:00 CST')) }
  after(:each) { Timecop.return }

  it 'can be created from valid attributes' do
    campaign = Campaign.new attributes
    expect(campaign).to be_valid
  end

  describe '#book_id' do
    it 'is required' do
      campaign = Campaign.new attributes.except(:book_id)
      expect(campaign).to have(1).error_on :book_id
    end
  end

  describe '#book' do
    it 'references the book to which the campaign belongs' do
      campaign = Campaign.new attributes
      expect(campaign.book.try(:id)).to eq book.id
    end
  end

  describe '#target_date' do
    it 'is required' do
      campaign = Campaign.new attributes.except(:target_date)
      expect(campaign).to have(1).error_on :target_date
    end

    it 'cannot be more than 60 days in the future' do
      campaign = Campaign.new attributes.merge(target_date: '2016-05-02')
      expect(campaign).to have(1).error_on :target_date
    end

    it 'must be after today' do
      campaign = Campaign.new attributes.merge(target_date: '2016-03-02')
      expect(campaign).to have(1).error_on :target_date
    end
  end

  describe '#target_amount' do
    it 'is required' do
      campaign = Campaign.new attributes.except(:target_amount)
      expect(campaign).to have_at_least(1).error_on :target_amount
    end

    it 'must be more than zero' do
      campaign = Campaign.new attributes.merge(target_amount: -1)
      expect(campaign).to have(1).error_on :target_amount
    end
  end

  describe '::current' do
    before(:all) { Timecop.freeze(DateTime.parse('2016-03-02 12:00:00 CST')) }
    after(:all) { Timecop.return }
    let!(:campaign) { FactoryGirl.create(:campaign, book: book, target_date: '2016-03-31') }
    it 'returns campaigns having target dates on or after today' do
      expect(Campaign.current.map(&:id)).to eq [campaign.id]
    end

    it 'does not include campaigns that have target dates in the past' do
      Timecop.freeze(DateTime.parse('2016-04-01 11:00:00 CST')) do
        expect(Campaign.current.map(&:id)).to eq []
      end
    end
  end

  describe '::past' do
    let!(:campaign) do
      Timecop.freeze(Date.parse('2016-01-01')) do
        FactoryGirl.create(:campaign, book: book, target_date: '2016-02-27')
      end
    end
    it 'returns campaigns having target dates that are in the past' do
      expect(Campaign.past.map(&:id)).to eq [campaign.id]
    end

    it 'does not include campaigns with target dates on or after today' do
      Timecop.freeze(Date.parse('2016-02-27 12:00:00 CST')) do
        expect(Campaign.past).to be_empty
      end
    end
  end

  shared_context :stateful_campaigns do
    let!(:unstarted1) { FactoryGirl.create(:unstarted_campaign) }
    let!(:unstarted2) { FactoryGirl.create(:unstarted_campaign) }
    let!(:active1) { FactoryGirl.create(:active_campaign) }
    let!(:active2) { FactoryGirl.create(:active_campaign) }
    let!(:collecting1) { FactoryGirl.create(:collecting_campaign) }
    let!(:collecting2) { FactoryGirl.create(:collecting_campaign) }
    let!(:collected1) { FactoryGirl.create(:collected_campaign) }
    let!(:collected2) { FactoryGirl.create(:collected_campaign) }
    let!(:cancelled1) { FactoryGirl.create(:cancelled_campaign) }
    let!(:cancelled2) { FactoryGirl.create(:cancelled_campaign) }
  end

  describe '::active' do
    include_context :stateful_campaigns
    it 'returns the campaigns that are currently active' do
      expect(Campaign.active.map(&:id)).to eq [active1.id, active2.id]
    end
  end

  describe '::unstarted' do
    include_context :stateful_campaigns
    it 'returns the campaigns that are currently unstarted' do
      expect(Campaign.unstarted.map(&:id)).to eq [unstarted1.id, unstarted2.id]
    end
  end

  describe '::collecting' do
    include_context :stateful_campaigns
    it 'returns the campaigns that are currently being collected' do
      expect(Campaign.collecting.map(&:id)).to eq [collecting1.id, collecting2.id]
    end
  end

  describe '::collected' do
    include_context :stateful_campaigns
    it 'returns the campaigns that have finished being collected' do
      expect(Campaign.collected.map(&:id)).to eq [collected1.id, collected2.id]
    end
  end

  describe '::cancelled' do
    include_context :stateful_campaigns
    it 'returns the campaigns that have been cancelled' do
      expect(Campaign.cancelled.map(&:id)).to eq [cancelled1.id, cancelled2.id]
    end
  end

  describe '#donations' do
    it 'is a list of the donations that have been made to the campaign' do
      campaign = Campaign.new attributes
      expect(campaign).to have(0).donations
    end
  end

  shared_context :donations do
    let (:campaign) { FactoryGirl.create(:campaign, target_amount: 500, target_date: '2016-03-31') }
    let!(:donation1) { FactoryGirl.create(:donation, campaign: campaign, amount: 25) }
    let!(:donation2) { FactoryGirl.create(:donation, campaign: campaign, amount: 50) }
  end

  describe '#total_donated' do
    include_context :donations
    it 'returns the sum of the donations' do
      expect(campaign.total_donated).to eq 75
    end
  end

  context 'before the target amount is reached' do
    include_context :donations

    describe '#donation_amount_needed' do
      it 'returns the difference between the target amount and the total donated' do
        expect(campaign.donation_amount_needed).to eq 425
      end
    end

    describe '#current_progress' do
      it 'returns a fractional value representing the progress toward the goal, where 1 means 100%' do
        expect(campaign.current_progress).to eq 0.15
      end
    end
  end

  context 'after the target amount is reached' do
    include_context :donations
    let!(:donation3) { FactoryGirl.create(:donation, campaign: campaign, amount: 426) }

    describe '#donation_amount_needed' do
      it 'returns zero' do
        expect(campaign.donation_amount_needed).to eq 0
      end
    end

    describe '#current_progress' do
      it 'returns 1' do
        expect(campaign.current_progress).to eq 1
      end
    end
  end

  describe '#days_remaining' do
    include_context :donations

    context 'before the target date' do
      before(:each) { Timecop.freeze(DateTime.parse('2016-03-02 12:00:00 CST')) }
      after(:each) { Timecop.return }

      it 'returns the number of days until the target date' do
        expect(campaign.days_remaining).to eq 29
      end
    end

    context 'on or after the target date' do
      before(:each) { Timecop.freeze(DateTime.parse('2016-04-01 12:00:00 CST')) }
      after(:each) { Timecop.return }

      it 'returns zero' do
        expect(campaign.days_remaining).to eq 0
      end
    end
  end

  describe '#rewards' do
    it 'is a list of donation rewards defined for the campaign' do
      campaign = Campaign.new attributes
      expect(campaign).to have(0).rewards
    end
  end

  context 'for an unstarted campaign' do
    let (:campaign) { FactoryGirl.create(:unstarted_campaign) }

    describe '#start' do
      it 'changes the state to "active"' do
        expect do
          campaign.start
        end.to change(campaign, :state).from('unstarted').to('active')
      end
    end

    describe '#collect' do
      it 'does not change the state' do
        expect do
          campaign.collect
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the donation payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.collect
      end
    end

    describe '#cancel' do
      it 'does not change the state' do
        expect do
          campaign.cancel
        end.not_to change(campaign, :state)
      end

      it 'does not queue any background jobs' do
        expect(Resque).not_to receive(:enqueue)
        campaign.cancel
      end
    end

    describe '#collect_donations' do
      it 'does not execute payment on any donation' do
        campaign.donations.each do |donation|
          expect(donation).not_to receive(:collect)
        end
        begin
          campaign.collect_donations
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.collect_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_donations' do
      let!(:donation1) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }
      let!(:donation2) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }

      it 'does not cancel any donations' do
        campaign.donations.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_donations
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_donations
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end

  context 'for an active campaign' do
    let (:campaign) { FactoryGirl.create(:active_campaign) }

    describe '#collect' do
      it 'changes the state to "collecting"' do
        expect do
          campaign.collect
        end.to change(campaign, :state).from('active').to('collecting')
      end

      it 'queues a job to execute the donation payments' do
        expect(Resque).to receive(:enqueue).with(DonationCollector, campaign.id)
        campaign.collect
      end
    end

    describe '#cancel' do
      it 'changes the state to "cancelling"' do
        expect do
          campaign.cancel
        end.to change(campaign, :state).from('active').to('cancelling')
      end

      it 'does not queue a job to execute the donation payments' do
        expect(Resque).not_to receive(:enqueue).with(DonationCollector, anything)
        campaign.cancel
      end

      it 'enqueues a job to void the payments' do
        expect(Resque).to receive(:enqueue).with(DonationCanceller, campaign.id)
        campaign.cancel
      end
    end

    describe '#collect_donations' do
      it 'does not execute payment on any donation' do
        campaign.donations.each do |donation|
          expect(donation).not_to receive(:collect)
        end
        begin
          campaign.collect_donations
        rescue
        end
      end

      it 'returns false' do
        expect do
          campaign.collect_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_donations' do
      let!(:donation1) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }
      let!(:donation2) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }

      it 'does not cancel any donations' do
        campaign.donations.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_donations
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_donations
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end

  context 'for a collected campaign' do
    let (:campaign) { FactoryGirl.create(:collected_campaign) }

    describe '#start' do
      it 'does not change the state' do
        expect do
          campaign.start
        end.not_to change(campaign, :state)
      end
    end

    describe '#collect' do
      it 'does not change the state' do
        expect do
          campaign.collect
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the donation payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.collect
      end
    end

    describe '#cancel' do
      it 'does not change the state' do
        expect do
          campaign.cancel
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the donation payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.cancel
      end
    end

    describe '#collect_donations' do
      it 'does not execute payment on any donation' do
        campaign.donations.each do |donation|
          expect(donation).not_to receive(:collect)
        end
        begin
          campaign.collect_donations
        rescue
        end
      end

      it 'returns false' do
        expect do
          campaign.collect_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_donations' do
      let!(:donation1) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }
      let!(:donation2) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }

      it 'does not cancel any donations' do
        campaign.donations.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_donations
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_donations
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end

  context 'for a cancelled campaign' do
    let (:campaign) { FactoryGirl.create(:cancelled_campaign) }

    describe '#collect' do
      it 'does not change the state' do
        expect do
          campaign.collect
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the donation payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.collect
      end
    end

    describe '#cancel' do
      it 'does not change the state' do
        expect do
          campaign.cancel
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the donation payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.cancel
      end
    end

    describe '#collect_donations' do
      it 'does not execute payment on any donation' do
        campaign.donations.each do |donation|
          expect(donation).not_to receive(:collect)
        end
        begin
          campaign.collect_donations
        rescue
        end
      end

      it 'returns false' do
        expect do
          campaign.collect_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_donations' do
      let!(:donation1) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }
      let!(:donation2) { FactoryGirl.create(:cancelled_donation, campaign: campaign) }

      it 'does not cancel any donations' do
        campaign.donations.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_donations
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_donations
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end

  context 'for a cancelling campaign' do
    let (:campaign) { FactoryGirl.create(:cancelling_campaign) }
    let!(:donation1) { FactoryGirl.create(:collected_donation, campaign: campaign) }
    let!(:donation2) { FactoryGirl.create(:collected_donation, campaign: campaign) }

    describe '#cancel_donations' do
      it 'returns true' do
        expect(campaign.cancel_donations).to be true
      end

      it 'cancels each donation' do
        campaign.donations.each do |d|
          expect(d).to receive(:cancel).and_return true
        end
        campaign.cancel_donations
      end

      it 'changes the state to "cancelled"' do
        expect do
          campaign.cancel_donations
        end.to change(campaign, :state).from('cancelling').to('cancelled')
      end
    end
  end

  context 'for a collecting campaign' do
    let (:campaign) { FactoryGirl.create(:collecting_campaign) }
    let!(:donation1) { FactoryGirl.create(:collected_donation, campaign: campaign, amount: 100) }
    let!(:donation2) { FactoryGirl.create(:collected_donation, campaign: campaign, amount: 125) }
    let!(:donation3) { FactoryGirl.create(:collected_donation, campaign: campaign, amount: 75) }
    let!(:payment1) { FactoryGirl.create(:payment, donation: donation1) }
    let!(:payment2) { FactoryGirl.create(:payment, donation: donation2) }
    let!(:payment3) { FactoryGirl.create(:payment, donation: donation3) }

    describe '#collect_donations' do
      context 'when all donations are collected successfully' do
        before(:each) { allow_any_instance_of(Donation).to receive(:collect).and_return(true) }

        it 'returns true' do
          expect(campaign.collect_donations).to be true
        end

        it 'changes the campaign state to "collected"' do
          expect do
            campaign.collect_donations
          end.to change(campaign, :state).from('collecting').to('collected')
        end
      end

      context 'when a donation collection fails' do

        # This won't be implemented until we have readers that can save the credit cards with us
        #it 'does not change the state of the campaign'
      end
    end

    describe '#cancel_donations' do
      it 'does not cancel any donations' do
        campaign.donations.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_donations
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_donations
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_donations
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end
end
