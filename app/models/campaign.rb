# == Schema Information
#
# Table name: campaigns
#
#  id                           :integer          not null, primary key
#  book_id                      :integer
#  target_amount                :decimal(, )
#  target_date                  :date
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  state                        :string(20)       default("unstarted"), not null
#  prolonged                    :boolean          default(FALSE), not null
#  success_notification_sent_at :time
#

class Campaign < ActiveRecord::Base
  belongs_to :book
  has_many :donations
  has_many :rewards

  validates_presence_of :book_id, :target_date, :target_amount
  validates_numericality_of :target_amount, greater_than: 0
  validate :target_date, :must_be_in_range, on: :create

  scope :current, ->{where('target_date >= ?', Date.today)}
  scope :past, ->{where('target_date < ?', Date.today)}
  scope :unstarted, ->{where(state: 'unstarted')}
  scope :active, ->{where(state: 'active')}
  scope :collecting, ->{where(state: 'collecting')}
  scope :collected, ->{where(state: 'collected')}
  scope :cancelling, ->{where(state: 'cancelling')}
  scope :cancelled, ->{where(state: 'cancelled')}
  scope :by_target_date, ->{order('target_date desc')}
  scope :not_unsubscribed, ->{joins(book: :author).where('users.unsubscribed = ?', false)}

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

  def self.send_progress_notifications
    #TODO We may need to change this if we end up with a lot of campaigns
    campaigns = active.by_target_date.not_unsubscribed
    campaigns.each do |campaign|
      begin
        CampaignMailer.progress(campaign).deliver_now
      rescue => e
        Rails.logger.error "Unable to send campaign progress email for campaign #{campaign.id}. #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      end
    end

    begin
      AdminMailer.campaign_progress(campaigns).deliver_now if campaigns.any?
    rescue => e
      Rails.logger.error "Unable to send campaign progress email to the administrator. #{e.class.name}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
    end
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
    raise Exceptions::InvalidCampaignStateError unless cancelling?
    finalize_cancellation if donations.map(&:cancel).all?
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
    raise Exceptions::InvalidCampaignStateError unless collecting?
    finalize_collection if donations.pledged.map(&:collect).all?
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

  def prolong
    return unless can_prolong?
    self.target_date = target_date + 15
    self.prolonged = true
    save
  end

  def can_prolong?
    active? && !prolonged?
  end

  def success_notification_sent?
    success_notification_sent_at.present?
  end

  def target_date_in_range?
    return false unless target_date
    target_date_range.cover?(target_date)
  end

  def target_amount_reached?
    donation_amount_needed == 0
  end

  private

  def must_be_in_range
    return unless target_date

    unless target_date_range.cover?(target_date)
      errors.add :target_date, 'must be between 30 and 60 days in the future'
    end
  end

  def maximum_target_date
    Date.today + 60
  end

  def minimum_target_date
    Date.today + 30
  end

  def queue_collection
    Resque.enqueue(DonationCollector, id)
  end

  def target_amount_achieved?
    total_donated >= target_amount
  end

  def target_date_range
    minimum_target_date..maximum_target_date
  end

  def void_donations
    Resque.enqueue(DonationCanceller, id)
  end
end
