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
end
