# == Schema Information
#
# Table name: campaigns
#
#  id            :integer          not null, primary key
#  book_id       :integer
#  target_amount :decimal(, )
#  target_date   :date
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  state         :string           default("paused"), not null
#

class Campaign < ActiveRecord::Base
  belongs_to :book
  has_many :donations
  has_many :rewards

  validates_presence_of :book_id, :target_date, :target_amount
  validates_numericality_of :target_amount, greater_than: 0
  validate :target_date, :is_in_range, on: :create

  scope :current, ->{where('target_date >= ?', Date.today)}
  scope :past, ->{where('target_date < ?', Date.today)}
  scope :unstarted, ->{where(state: 'unstarted')}
  scope :active, ->{where(state: 'active')}
  scope :collecting, ->{where(state: 'collecting')}
  scope :collected, ->{where(state: 'collected')}
  scope :cancelling, ->{where(state: 'cancelling')}
  scope :cancelled, ->{where(state: 'cancelled')}

  state_machine :initial => :unstarted do
    before_transition :active => :collecting, :do => :queue_collection
    after_transition :active => :cancelling, :do => :void_donations
    event :start do
      transition :unstarted => :active
    end
    event :collect do
      transition :active => :collecting
    end
    event :cancel do
      transition :active => :cancelling
    end
    event :finalize_collection do
      transition :collecting => :collected
    end
    event :finalize_cancellation do
      transition :cancelling => :cancelled
    end
    state :unstarted, :active, :collecting, :collected, :cancelling, :cancelled
  end

  def author
    book.try(:author)
  end

  # Iterates through the donations and attempts
  # to cancel each
  #
  # Returns true if successful in cancelling all
  # donations. Otherwise returns false.
  #
  # The campaign must be in the 'cancelling' state.
  # If not, the method exists and returns false
  def cancel_donations
    if cancelling?
      result = donations.map(&:cancel).all?
      finalize_cancellation if result
    else
      Rails.logger.warn "Campaign#cancel_donations called on id=#{id}, which is currently in the state #{state}. This call has been ignored."
      false
    end
  end

  # Iterates through the donations and attempts
  # to collect payment on each.
  #
  # Returns true if success in collecting from all
  # donations, otherwise false.
  #
  # The campaign must be in the 'collecting' state.
  # If not, the method exists and returns false
  def collect_donations
    if collecting?
      result = donations.pledged.map(&:collect).all?
      finalize_collection if result
    else
      Rails.logger.warn "Campaign#collect_donations called on id=#{id} which is currently in state #{state}. This call has been ignored."
      false
    end
  end

  def total_donated
    donations.reduce(0){|sum, d| sum + d.amount}
  end

  def donation_amount_needed
    return 0 if target_amount_achieved?
    target_amount - total_donated
  end

  def current_progress
    return 1 if target_amount_achieved?
    total_donated / target_amount
  end

  def days_remaining
    return 0 if expired?
    (target_date - Date.today).to_i
  end

  def expired?
    Date.today >= target_date
  end

  private

  def is_in_range
    return unless target_date

    if Date.today >= target_date.to_date
      errors.add :target_date, 'must be after today'
    end

    if maximum_target_date < target_date.to_date
      errors.add :target_date, 'must be within 60 days'
    end
  end

  def maximum_target_date
    Date.today + 60
  end

  def queue_collection
    Resque.enqueue(DonationCollector, id)
  end

  def target_amount_achieved?
    total_donated >= target_amount
  end

  def void_donations
    Resque.enqueue(DonationCanceller, id)
  end
end
