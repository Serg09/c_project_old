class Link
  include ActiveModel::Validations

  SITES = {
    facebook:  { label: 'Facebook',  host: 'facebook.com' },
    youtube:   { label: 'YouTube',   host: 'youtube.com'  },
    twitter:   { label: 'Twitter',   host: 'twitter.com'  },
    tumblr:    { label: 'Tumblr',    host: 'tumblr.com'   },
    instagram: { label: 'Instagram', host: 'instagram.com'},
    linkedin:  { label: 'LinkedIn',  host: 'linkedin.com' }
  }.with_indifferent_access

  def self.blank_links
    SITES.keys.map{|site| Link.new(site: site)}
  end

  def self.site_label(key)
    SITES[key][:label]
  end

  def self.load(value)
    return blank_links unless value

    saved_links = JSON.load(value).map{|a| Link.new(a)}
    blank_links.map do |blank|
      saved = saved_links.
        select{|l| l.site == blank.site}.
        first
      saved || blank
    end
  end

  def self.dump(links)
    JSON.dump(links.select{|l| l.url.present?}.map(&:attributes))
  end

  attr_accessor :site, :url

  validates_presence_of :site
  validates_inclusion_of :site, in: SITES.keys
  validate :url, :is_a_valid_url

  def initialize(attributes = {})
    attributes = (attributes || {}).with_indifferent_access
    self.site = attributes[:site]
    self.url = attributes[:url]
  end

  def attributes
    {
      site: self.site,
      url: self.url
    }
  end

  def marked_for_destruction?
    false
  end

  private

  def is_a_valid_url
    return unless url && url.present?
    uri = URI.parse(url)
    site_record = SITES[site]
    errors.add :url, 'domain name must match the site' unless site_record && uri.host.end_with?(site_record[:host])
    errors.add :url, 'must be a full URL' unless !!uri.scheme && !!uri.host && !!uri.path
  rescue URI::InvalidURIError
    errors.add :url, 'must be a valid URL'
  end
end
