class Bio < ActiveRecord::Base
  belongs_to :author
  serialize :links, Array
  validates_presence_of :author_id, :text
  validate :links, :contains_valid_links

  STATUSES = %w(pending approved rejected)

  class << self
    STATUSES.each do |status|
      define_method status.upcase do
        status
      end
    end
  end

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
