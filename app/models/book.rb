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
  validates_presence_of :author_id
  has_many :versions, class_name: 'BookVersion', dependent: :destroy, autosave: true

  delegate :pending?,
    :approved?,
    :rejected?,
    :title,
    :short_description,
    :long_description,
    :cover_image_id,
    :sample_id,
    :genres,
    :status,
    to: :working_version

  def approve
    pending_version.status = BookVersion.APPROVED
    self.status = BookVersion.APPROVED
    pending_version.save && save
  end

  def reload
    super
    @pending_version = nil
    @working_version = nil
  end

  def reject
    pending_version.status = BookVersion.REJECTED
    self.status = BookVersion.REJECTED
    pending_version.save && save
  end

  # Override the default implementation in order to handle the versioning
  def update_attributes(attributes)
    @working_version = nil
    if latest_version.approved? || versions.none?
      versions.new(attributes)
    elsif latest_version.rejected? || latest_version.pending?
      latest_version.update_attributes attributes.merge(status: BookVersion.PENDING)
    end
    version = BookVersion.PENDING
  end

  private

  def latest_version
    versions.order('created_at desc').first
  end

  def lookup_working_version
    versions.first
  end

  def pending_version
    @pending_version ||= versions.pending.first # assumes pending is sorted by date desc
  end

  def working_version
    @working_version ||= lookup_working_version
  end
end
