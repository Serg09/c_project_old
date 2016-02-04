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

  MAX_IMAGE_WIDTH = 1024
  MAX_IMAGE_HEIGHT = 1024

  before_save :process_photo_file

  belongs_to :author
  belongs_to :photo, class_name: Image
  validates_associated :links
  serialize :links, Link
  validates_presence_of :author_id, :text, :status
  validates_inclusion_of :status, in: STATUSES
  
  attr_accessor :photo_file

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

  def links_attributes=(list)
    if list
      self.links = list.map do |attr|
        Link.new(attr)
      end
    else
      self.links = []
    end
  end

  def usable_links
    links.select{|link| link.url.present?}
  end

  private

  def photo_file_mime_type
    return photo_file.content_type if photo_file.respond_to?(:content_type)
    'image/jpeg'
  end

  def process_photo_file
    return unless photo_file

    magick = Magick::Image.from_blob(photo_file.read).first
    scaled_magick = magick.resize_to_fit MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT
    image = find_or_create_image(scaled_magick.to_blob)
    self.photo_id = image.id
  end

  def find_or_create_image(data)
    hash_id = Image.hash_id(data)
    image = Image.find_by(hash_id: hash_id)
    unless image
      image_binary = ImageBinary.create!(data: data)
      image = Image.create!(author: author,
                            image_binary: image_binary,
                            hash_id: hash_id,
                            mime_type: photo_file_mime_type)

    end
    image
  end
end
