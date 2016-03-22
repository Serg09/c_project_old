require 'rails_helper'

RSpec.describe Campaign, type: :model do
  let (:book) { FactoryGirl.create(:approved_book) }

  let (:attributes) do
    {
      book_id: book.id,
      target_date: Date.new(2016, 3, 31),
      target_amount: 5_000,
      paused: true
    }
  end

  before(:all) { Timecop.freeze(DateTime.parse('2016-03-02 12:00:00 CST')) }
  after(:all) { Timecop.return }

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

  describe '#paused' do
    it 'defaults to true' do
      campaign = Campaign.new attributes.except(:paused)
      expect(campaign).to be_valid
      expect(campaign).to be_paused
    end
  end

  describe '#active?' do
    let!(:bio) { FactoryGirl.create(:approved_bio, author: book.author) }

    it 'is true if the campaign is not paused, the target date has not passed, the book is approved, and the author bio is approved' do
      campaign = Campaign.new attributes.merge(paused: false)
      expect(campaign).to be_active
    end

    it 'is false if the campaign is paused' do
      campaign = Campaign.new attributes
      expect(campaign).not_to be_active
    end

    it 'is false if the campaign target date is in the past' do
      campaign = Campaign.new attributes.merge(paused: false)
      Timecop.freeze('2016-04-01') do
        expect(campaign).not_to be_active
      end
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
end
