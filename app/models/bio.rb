# == Schema Information
#
# Table name: bios
#
#  id         :integer          not null, primary key
#  author_id  :integer          not null
#  text       :text             not null
#  photo_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  links      :text
#  status     :string           default("pending"), not null
#

class Bio < ActiveRecord::Base
  STATUSES = %w(pending approved rejected)

  belongs_to :author
  serialize :links, Array
  validates_presence_of :author_id, :text, :status
  validates_inclusion_of :status, in: STATUSES
  validate :links, :contains_valid_links

  class << self
    STATUSES.each do |status|
      define_method status.upcase do
        status
      end
    end
  end

  STATUSES.each do |status|
    define_method "#{status}?" do
      self.status == status
    end
  end

  scope :pending, -> { where(status: Bio.PENDING).order('created_at DESC') }
  scope :approved, -> { where(status: Bio.APPROVED).order('created_at DESC') }

  private

  def contains_valid_links
    link_errors = links.map{ |l| validate_link(l) }.flatten
    errors.add(:links, link_errors.to_sentence) if link_errors.any?
  end

  def validate_link(link)
    result = []
    result << 'Site must be specified' unless link.has_key?(:site)
    result << 'URL must be specified' unless link.has_key?(:url)
    result
  end
end
