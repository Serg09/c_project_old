class Link
  include ActiveModel::Validations

  SITES = {
    facebook:  { label: 'Facebook',  host: 'www.facebook.com' },
    youtube:   { label: 'YouTube',   host: 'www.youtube.com'  },
    twitter:   { label: 'Twitter',   host: 'www.twitter.com'  },
    tumblr:    { label: 'Tumblr',    host: 'www.tumblr.com'   },
    instagram: { label: 'Instagram', host: 'www.instagram.com'},
    linkedin:  { label: 'LinkedIn',  host: 'www.linkedin.com' }
  }

  attr_accessor :site, :url

  validates_presence_of :site, :url
  validates_inclusion_of :site, in: SITES.keys
  validate :url, :is_a_valid_url

  def initialize(attributes = {})
    attributes ||= {}
    self.site = attributes[:site]
    self.url = attributes[:url]
  end

  private

  def is_a_valid_url
    uri = URI.parse(url)
    site_record = SITES[site]
    errors.add :url, 'domain name must match the site' unless site_record && uri.host == site_record[:host]
    errors.add :url, 'must be a full URL' unless !!uri.scheme && !!uri.host && !!uri.path
  rescue URI::InvalidURIError
    errors.add :url, 'must be a valid URL'
  end
end
