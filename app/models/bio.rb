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

  before_save :save_photo

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

  def save_photo
    return unless photo_file
    data = photo_file.read
    hash_id = Image.hash_id(data)
    image = Image.find_by(hash_id: hash_id)
    unless image
      image_binary = ImageBinary.create!(data: data)
      image = Image.create!(author: author,
                            image_binary: image_binary,
                            hash_id: hash_id,
                            mime_type: 'image/jpeg') # TODO Read this from the input file

    end
    self.photo_id = image.id
  end
end
