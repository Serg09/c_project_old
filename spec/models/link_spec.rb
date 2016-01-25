require 'rails_helper'

RSpec.describe Link, type: :model do
  let (:attributes) do
    {
      site: :facebook,
      url: 'http://www.facebook.com/john_doe'
    }
  end

  it 'can be created from valid attributes' do
    link = Link.new(attributes)
    expect(link).to be_valid
  end

  describe '#site' do
    it 'is required' do
      link = Link.new attributes.except(:site)
      expect(link).to have_at_least(1).error_on :site
    end

    it 'cannot be anything other than Facebook, Twitter, YouTube, Instagram, Tumblr, or LinkedIn' do
      link = Link.new attributes.merge(site: 'SomeOtherSite')
      expect(link).to have_at_least(1).error_on :site
    end
  end

  describe '#url' do
    it 'is required' do
      link = Link.new attributes.except(:url)
      expect(link).to have_at_least(1).error_on :url
    end

    it 'must be a valid, fully qualified URL' do
      link = Link.new attributes.merge(url: 'notavalidurl')
      expect(link).to have_at_least(1).error_on :url
    end

    it 'must have a domain name that matches the specified site' do
      link = Link.new attributes.merge(url: 'http://www.unrelatedsite.com/')
      expect(link).to have_at_least(1).error_on :url
    end
  end
end
