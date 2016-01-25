class Link < ActiveRecord::Base
  belongs_to :bio

  validates_presence_of :bio_id

  SITES = %w(Facebook LinkedIn Twitter Tumblr Instagram)

  class << self
    SITES.each do |site|
      define_method site.upcase do
        site
      end
    end
  end
end
