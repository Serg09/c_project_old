class Link
  include ActiveModel::Validations

  SITES = {
    facebook:  { label: 'Facebook',  host: 'www.facebook.com' },
    youtube:   { label: 'YouTube',   host: 'www.youtube.com'  },
    twitter:   { label: 'Twitter',   host: 'www.twitter.com'  },
    tumblr:    { label: 'Tumblr',    host: 'www.tumblr.com'   },
    instagram: { label: 'Instagram', host: 'www.instagram.com'},
    linkedin:  { label: 'LinkedIn',  host: 'www.linkedin.com' }
  }.with_indifferent_access

  def self.blank_links
    SITES.keys.map{|site| Link.new(site: site)}
  end

  def self.site_label(key)
    SITES[key][:label]
  end

  attr_accessor :site, :url

  validates_presence_of :site
  validates_inclusion_of :site, in: SITES.keys
  validate :url, :is_a_valid_url

  def initialize(attributes = {})
    attributes ||= {}
    self.site = attributes[:site]
    self.url = attributes[:url]
  end

  def marked_for_destruction?
    false
  end

  private

  def is_a_valid_url
    return unless url && url.present?
    uri = URI.parse(url)
    site_record = SITES[site]
    errors.add :url, 'domain name must match the site' unless site_record && uri.host == site_record[:host]
    errors.add :url, 'must be a full URL' unless !!uri.scheme && !!uri.host && !!uri.path
  rescue URI::InvalidURIError
    errors.add :url, 'must be a valid URL'
  end
end
