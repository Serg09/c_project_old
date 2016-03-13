# == Schema Information
#
# Table name: campaigns
#
#  id            :integer          not null, primary key
#  book_id       :integer
#  target_amount :decimal(, )
#  target_date   :date
#  paused        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Campaign < ActiveRecord::Base
  belongs_to :book

  validates_presence_of :book_id, :target_date, :target_amount
  validates_numericality_of :target_amount, greater_than: 0
  validate :target_date, :is_in_range

  before_validation :set_defaults

  scope :current, ->{where('target_date > ?', Date.today)}

  def active?
    return false unless author.active_bio.present?
    Date.today <= target_date && !paused?
  end

  def author
    book.try(:author)
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

  def set_defaults
    self.paused = true if self.paused.nil?
  end
end
