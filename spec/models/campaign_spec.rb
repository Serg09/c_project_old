require 'rails_helper'

RSpec.describe Campaign, type: :model do
  let (:book) { FactoryGirl.create(:approved_book) }

  let (:attributes) do
    {
      book_id: book.id,
      target_date: Date.new(2016, 4, 30),
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

  describe '#success_notification_sent?' do
    let (:campaign) { FactoryGirl.create(:campaign) }

    it 'is false if #success_notification_sent_at is nil' do
      expect(campaign.success_notification_sent?).to be false
    end

    it 'is true if #success_notification_sent_at has a value' do
      campaign.success_notification_sent_at = DateTime.now
      expect(campaign.success_notification_sent?).to be true
    end
  end

  describe '#target_amount_reached?' do
    let (:campaign) { FactoryGirl.create(:campaign, target_amount: 500) }
    let!(:contribution) { FactoryGirl.create(:contribution, campaign: campaign, amount: 499) }
    let (:contribution2) { FactoryGirl.create(:contribution, campaign: campaign, amount: 1) }

    it 'is false if the total donated is less than #target_amount' do
      expect(campaign.target_amount_reached?).to be false
    end

    it 'is true if the total dontated is equal to or more than #target_amount' do
      contribution2
      expect(campaign.target_amount_reached?).to be true
    end
  end

  shared_context :contributions_and_fulfillments do
    let (:campaign) { FactoryGirl.create(:active_campaign) }
    let (:house_reward) do
      FactoryGirl.create(:physical_house_reward, estimator_class: 'PublishingCostEstimator')
    end
    let (:physical_reward) do
      FactoryGirl.create(:reward, campaign: campaign,
                                  house_reward: house_reward)
    end
    let (:other_reward) { FactoryGirl.create(:reward, campaign: campaign) }
    let (:c1) do
      FactoryGirl.create(:collected_contribution, campaign: campaign,
                                                  amount: 100,
                                                  provider_fee: 1.00)
    end
    let!(:f1) do
      FactoryGirl.create(:physical_fulfillment, contribution: c1,
                                                reward: physical_reward)
    end
    let (:c2) do
      FactoryGirl.create(:collected_contribution, campaign: campaign,
                                                  amount: 200,
                                                  provider_fee: 1.50)
    end
    let!(:f2) do
      FactoryGirl.create(:physical_fulfillment, contribution: c2,
                                                reward: other_reward)
    end
    let (:c3) do
      FactoryGirl.create(:collected_contribution, campaign: campaign,
                                                  amount: 300,
                                                  provider_fee: 1.75)
    end
    let!(:f3) do
      FactoryGirl.create(:physical_fulfillment, contribution: c3,
                                                reward: physical_reward)
    end

    before do
      allow_any_instance_of(PublishingCostEstimator).to \
        receive(:estimate).
        and_return(5)
    end
  end

  describe '#estimated_cost_of_rewards' do
    include_context :contributions_and_fulfillments

    it 'aggregates the estimated cost of the rewards' do
      expect(campaign.estimated_cost_of_rewards).to eq 5
    end
  end

  describe '#estimated_cost_of_payments' do
    let (:campaign) { FactoryGirl.create(:campaign) }
    let!(:c1) { FactoryGirl.create(:collected_contribution, campaign: campaign, provider_fee: 1.00) }
    let!(:c2) { FactoryGirl.create(:collected_contribution, campaign: campaign, provider_fee: 1.50) }
    let!(:c3) { FactoryGirl.create(:collected_contribution, campaign: campaign, provider_fee: 2.00) }

    it 'aggregates the fees from the payments' do
      expect(campaign.estimated_cost_of_payments).to eq 4.50
    end
  end

  describe '#estimated_amount_available' do
    include_context :contributions_and_fulfillments

    it 'is the total contributions less est. cost of rewards and payment fees' do
      # 100 + 200 + 300 - (1.00 + 1.50 + 1.75) - 5
      expect(campaign.estimated_amount_available).to eq 590.75
    end
  end

  describe '::send_progress_notifications' do
    let (:unsubscribed_author) { FactoryGirl.create(:user, unsubscribed: true) }
    let (:book_1) { FactoryGirl.create(:book, title: "You've Got Mail") }
    let (:book_2) { FactoryGirl.create(:book, title: "Manage Your Inbox") }
    let (:book_3) { FactoryGirl.create(:book, author: unsubscribed_author) }
    let!(:active_1) { FactoryGirl.create(:active_campaign, book: book_1) }
    let!(:active_2) { FactoryGirl.create(:active_campaign, book: book_2) }
    let!(:active_3) { FactoryGirl.create(:active_campaign, book: book_3) }
    let!(:unstarted) { FactoryGirl.create(:unstarted_campaign) }
    let!(:collecting) { FactoryGirl.create(:collecting_campaign) }
    let!(:collected) { FactoryGirl.create(:collected_campaign) }
    let!(:cancelling) { FactoryGirl.create(:cancelling_campaign) }
    let!(:cancelled) { FactoryGirl.create(:cancelled_campaign) }

    let (:not_active) { [unstarted, collecting, collected, cancelling, cancelled] }

    it 'sends an email to the author (if subscribed) for each active campaign' do
      Campaign.send_progress_notifications
      expect(book_1.author.email).to receive_an_email_with_subject("Campaign progress: You've Got Mail")
      expect(book_2.author.email).to receive_an_email_with_subject("Campaign progress: Manage Your Inbox")
    end

    it 'does not send an email for campaigns that are not active' do
      Campaign.send_progress_notifications
      not_active.each do |campaign|
        expect(campaign.book.author.email).not_to receive_an_email_with_subject(/^Campaign progress/)
      end
    end

    it 'does not send an email to authors with active campaigns that are unsubscribed' do
      Campaign.send_progress_notifications
      expect(unsubscribed_author.email).not_to receive_an_email_with_subject(/^Campaign progress/)
    end

    it 'sends one email to the administrator for all active campaigns' do
      Campaign.send_progress_notifications
      expect('info@crowdscribed.com').to receive_an_email_with_subject("Campaign progress")
    end
  end

  describe '::current' do
    before(:all) { Timecop.freeze(DateTime.parse('2016-03-02 12:00:00 CST')) }
    after(:all) { Timecop.return }
    let!(:campaign) { FactoryGirl.create(:campaign, book: book, target_date: '2016-04-30') }
    it 'returns campaigns having target dates on or after today' do
      expect(Campaign.current.map(&:id)).to eq [campaign.id]
    end

    it 'does not include campaigns that have target dates in the past' do
      Timecop.freeze(DateTime.parse('2016-05-01 11:00:00 CST')) do
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

  describe '#contributions' do
    it 'is a list of the contributions that have been made to the campaign' do
      campaign = Campaign.new attributes
      expect(campaign).to have(0).contributions
    end
  end

  shared_context :contributions do
    let (:campaign) { FactoryGirl.create(:campaign, target_amount: 500, target_date: '2016-04-30') }
    let!(:contribution1) { FactoryGirl.create(:contribution, campaign: campaign, amount: 25) }
    let!(:contribution2) { FactoryGirl.create(:contribution, campaign: campaign, amount: 50) }
  end

  describe '#total_donated' do
    include_context :contributions
    it 'returns the sum of the contributions' do
      expect(campaign.total_donated).to eq 75
    end
  end

  context 'before the target amount is reached' do
    include_context :contributions

    describe '#contribution_amount_needed' do
      it 'returns the difference between the target amount and the total donated' do
        expect(campaign.contribution_amount_needed).to eq 425
      end
    end

    describe '#current_progress' do
      it 'returns a fractional value representing the progress toward the goal, where 1 means 100%' do
        expect(campaign.current_progress).to eq 0.15
      end
    end
  end

  context 'after the target amount is reached' do
    include_context :contributions
    let!(:contribution3) { FactoryGirl.create(:contribution, campaign: campaign, amount: 426) }

    describe '#contribution_amount_needed' do
      it 'returns zero' do
        expect(campaign.contribution_amount_needed).to eq 0
      end
    end

    describe '#current_progress' do
      it 'returns 1' do
        expect(campaign.current_progress).to eq 1
      end
    end
  end

  describe '#days_remaining' do
    include_context :contributions

    context 'before the target date' do
      before(:each) { Timecop.freeze(DateTime.parse('2016-03-02 12:00:00 CST')) }
      after(:each) { Timecop.return }

      it 'returns the number of days until the target date' do
        expect(campaign.days_remaining).to eq 59
      end
    end

    context 'on or after the target date' do
      before(:each) { Timecop.freeze(DateTime.parse('2016-06-01 12:00:00 CST')) }
      after(:each) { Timecop.return }

      it 'returns zero' do
        expect(campaign.days_remaining).to eq 0
      end
    end
  end

  describe '#rewards' do
    it 'is a list of contribution rewards defined for the campaign' do
      campaign = Campaign.new attributes
      expect(campaign).to have(0).rewards
    end
  end

  context 'for an unstarted campaign' do
    let (:author) { FactoryGirl.create(:author_user) }
    let (:book) { FactoryGirl.create(:approved_book, author: author) }
    let (:campaign) do
      FactoryGirl.create(:unstarted_campaign, agree_to_terms: true,
                                              book: book)
    end

    describe '#author_ready?' do
      context 'when the author has an approved bio' do
        it 'is true' do
          expect(campaign.author_ready?).to be true
        end
      end
      context 'when the author does not have an approved bio' do
        let (:author) { FactoryGirl.create(:user) }

        it 'is false' do
          expect(campaign.author_ready?).to be false
        end
      end
    end

    context 'when terms have been agreed to' do
      describe '#start' do
        it 'changes the state to "active"' do
          expect do
            campaign.start
          end.to change(campaign, :state).from('unstarted').to('active')
        end
      end
    end

    context 'when terms have not been agreed to' do
      let (:campaign) { FactoryGirl.create(:unstarted_campaign, agree_to_terms: false) }

      describe '#start' do
        it 'does not change the state' do
          expect do
            campaign.start
          end.not_to change(campaign, :state)
        end
      end
    end

    describe '#collect' do
      it 'does not change the state' do
        expect do
          campaign.collect
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the contribution payments' do
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

    describe '#collect_contributions' do
      it 'does not execute payment on any contribution' do
        campaign.contributions.each do |contribution|
          expect(contribution).not_to receive(:collect)
        end
        begin
          campaign.collect_contributions
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.collect_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_contributions' do
      let!(:contribution1) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }
      let!(:contribution2) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }

      it 'does not cancel any contributions' do
        campaign.contributions.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_contributions
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_contributions
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end

  context 'for an active campaign' do
    let (:target_date) { Date.new(2016, 4, 30) }
    let (:campaign) { FactoryGirl.create(:active_campaign, target_date: target_date) }

    context 'that has not been prolonged' do
      describe '#prolong' do
        it 'changes #target_date to 15 days later' do
          expect do
            campaign.prolong
          end.to change(campaign, :target_date).from(target_date).to(Date.new(2016, 5, 15))
        end

        it 'sets #prolonged? to true' do
          expect do
            campaign.prolong
          end.to change(campaign, :prolonged).from(false).to(true)
        end
      end
    end

    context 'that has been prolonged' do
      let (:campaign) { FactoryGirl.create(:active_campaign, prolonged: true) }
      it 'does not change #target_date' do
        expect do
          campaign.prolong
        end.not_to change(campaign, :target_date)
      end

      it 'does not change #prolonged' do
        expect do
          campaign.prolong
        end.not_to change(campaign, :prolonged)
      end
    end

    describe '#collect' do
      it 'changes the state to "collecting"' do
        expect do
          campaign.collect
        end.to change(campaign, :state).from('active').to('collecting')
      end

      it 'queues a job to execute the contribution payments' do
        expect(Resque).to receive(:enqueue).with(ContributionCollector, campaign.id)
        campaign.collect
      end
    end

    describe '#cancel' do
      it 'changes the state to "cancelling"' do
        expect do
          campaign.cancel
        end.to change(campaign, :state).from('active').to('cancelling')
      end

      it 'does not queue a job to execute the contribution payments' do
        expect(Resque).not_to receive(:enqueue).with(ContributionCollector, anything)
        campaign.cancel
      end

      it 'enqueues a job to void the payments' do
        expect(Resque).to receive(:enqueue).with(ContributionCanceller, campaign.id)
        campaign.cancel
      end
    end

    describe '#collect_contributions' do
      it 'does not execute payment on any contribution' do
        campaign.contributions.each do |contribution|
          expect(contribution).not_to receive(:collect)
        end
        begin
          campaign.collect_contributions
        rescue
        end
      end

      it 'returns false' do
        expect do
          campaign.collect_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_contributions' do
      let!(:contribution1) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }
      let!(:contribution2) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }

      it 'does not cancel any contributions' do
        campaign.contributions.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_contributions
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_contributions
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

    describe '#prolong' do
      it 'does not change #target_date' do
        expect do
          campaign.prolong
        end.not_to change(campaign, :target_date)
      end

      it 'does not change #prolonged' do
        expect do
          campaign.prolong
        end.not_to change(campaign, :prolonged)
      end
    end

    describe '#collect' do
      it 'does not change the state' do
        expect do
          campaign.collect
        end.not_to change(campaign, :state)
      end

      it 'does not queue a job to execute the contribution payments' do
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

      it 'does not queue a job to execute the contribution payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.cancel
      end
    end

    describe '#collect_contributions' do
      it 'does not execute payment on any contribution' do
        campaign.contributions.each do |contribution|
          expect(contribution).not_to receive(:collect)
        end
        begin
          campaign.collect_contributions
        rescue
        end
      end

      it 'returns false' do
        expect do
          campaign.collect_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_contributions' do
      let!(:contribution1) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }
      let!(:contribution2) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }

      it 'does not cancel any contributions' do
        campaign.contributions.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_contributions
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_contributions
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

      it 'does not queue a job to execute the contribution payments' do
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

      it 'does not queue a job to execute the contribution payments' do
        expect(Resque).not_to receive(:enqueue)
        campaign.cancel
      end
    end

    describe '#collect_contributions' do
      it 'does not execute payment on any contribution' do
        campaign.contributions.each do |contribution|
          expect(contribution).not_to receive(:collect)
        end
        begin
          campaign.collect_contributions
        rescue
        end
      end

      it 'returns false' do
        expect do
          campaign.collect_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end
    end

    describe '#cancel_contributions' do
      let!(:contribution1) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }
      let!(:contribution2) { FactoryGirl.create(:cancelled_contribution, campaign: campaign) }

      it 'does not cancel any contributions' do
        campaign.contributions.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_contributions
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_contributions
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end

  context 'for a cancelling campaign' do
    let (:campaign) { FactoryGirl.create(:cancelling_campaign) }
    let!(:contribution1) { FactoryGirl.create(:collected_contribution, campaign: campaign) }
    let!(:contribution2) { FactoryGirl.create(:collected_contribution, campaign: campaign) }

    describe '#cancel_contributions' do
      it 'returns true' do
        expect(campaign.cancel_contributions).to be true
      end

      it 'cancels each contribution' do
        campaign.contributions.each do |d|
          expect(d).to receive(:cancel!).and_return true
        end
        campaign.cancel_contributions
      end

      it 'changes the state to "cancelled"' do
        expect do
          campaign.cancel_contributions
        end.to change(campaign, :state).from('cancelling').to('cancelled')
      end
    end
  end

  context 'for a collecting campaign' do
    let (:campaign) { FactoryGirl.create(:collecting_campaign) }
    let!(:contribution1) { FactoryGirl.create(:collected_contribution, campaign: campaign, amount: 100) }
    let!(:contribution2) { FactoryGirl.create(:collected_contribution, campaign: campaign, amount: 125) }
    let!(:contribution3) { FactoryGirl.create(:collected_contribution, campaign: campaign, amount: 75) }
    let!(:payment1) { FactoryGirl.create(:payment, contribution: contribution1) }
    let!(:payment2) { FactoryGirl.create(:payment, contribution: contribution2) }
    let!(:payment3) { FactoryGirl.create(:payment, contribution: contribution3) }

    describe '#collect_contributions' do
      context 'when all contributions are collected successfully' do
        before(:each) { allow_any_instance_of(Contribution).to receive(:collect).and_return(true) }

        it 'returns true' do
          expect(campaign.collect_contributions).to be true
        end

        it 'changes the campaign state to "collected"' do
          expect do
            campaign.collect_contributions
          end.to change(campaign, :state).from('collecting').to('collected')
        end
      end

      context 'when a contribution collection fails' do

        # This won't be implemented until we have readers that can save the credit cards with us
        #it 'does not change the state of the campaign'
      end
    end

    describe '#cancel_contributions' do
      it 'does not cancel any contributions' do
        campaign.contributions.each do |d|
          expect(d).not_to receive(:cancel)
        end
        begin
          campaign.cancel_contributions
        rescue
        end
      end

      it 'raises InvalidCampaignStateError' do
        expect do
          campaign.cancel_contributions
        end.to raise_error Exceptions::InvalidCampaignStateError
      end

      it 'does not change the state' do
        expect do
          begin
            campaign.cancel_contributions
          rescue
          end
        end.not_to change(campaign, :state)
      end
    end
  end
end
