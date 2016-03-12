# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  author_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Book < ActiveRecord::Base
  belongs_to :author
  has_many :versions, class_name: 'BookVersion', dependent: :destroy, autosave: true
  has_many :campaigns
  validates_presence_of :author_id

  scope :pending, ->{ where(status: BookVersion.PENDING).order('created_at desc') }
  scope :approved, ->{ where(status: BookVersion.APPROVED).order('created_at desc') }
  scope :rejected, ->{ where(status: BookVersion.REJECTED).order('created_at desc') }

  def active_campaign
    @active_campaign ||= campaigns.current.select{|c| c.active?}.first
  end

  def approved?
    approved_version.present? && pending_version.blank?
  end

  def approved_version
    @approved_version ||= versions.approved.first
  end

  # Creates an returns a new book instance with
  # a new book version instance for the specified
  # author. Parameters are
  # applied if they are specified
  def self.new_book(author, params = {})
    book = author.books.new
    book.pending_version = book.versions.new (params || {}).merge(book: book)
    book
  end

  def new_version!(params)
    @pending_version = versions.new params
    @pending_version.save
  end

  def pending?
    pending_version.present?
  end

  def pending_version
    @pending_version ||= versions.pending.first
  end

  def pending_version=(version)
    @pending_version = version
  end

  def reload
    super
    @pending_version = nil
    @working_version = nil
  end

  def rejected?
    rejected_version.present? &&
      approved_version.blank? &&
      pending_version.blank?
  end

  def rejected_version
    @rejected_version ||= versions.rejected.first
  end

  def public_title
    approved_version.try(:title)
  end

  def administrative_title
    working_version.title
  end

  def working_version
    pending_version || approved_version || rejected_version
  end
end
