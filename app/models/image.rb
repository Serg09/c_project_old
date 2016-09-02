# == Schema Information
#
# Table name: images
#
#  id              :integer          not null, primary key
#  owner_id         :integer          not null
#  image_binary_id :integer          not null
#  hash_id         :string(40)       not null
#  mime_type       :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Image < ActiveRecord::Base
  MAX_IMAGE_WIDTH = 1024
  MAX_IMAGE_HEIGHT = 1024

  belongs_to :owner, polymorphic: true
  belongs_to :image_binary
  has_many :bios, foreign_key: 'photo_id'
  has_many :cover_of_book_versions, foreign_key: 'cover_image_id', class_name: 'BookVersion'
  has_many :sample_of_book_versions, foreign_key: 'sample_id', class_name: 'BookVersion'
  has_many :reward_photos, foreign_key: 'photo_id', class_name: 'Reward'

  validates_presence_of :owner_id, :owner_type, :image_binary_id, :hash_id
  validates_length_of :hash_id, is: 40
  validates_uniqueness_of :hash_id

  def self.hash_id(data)
    Digest::SHA1.hexdigest(data)
  end

  def self.find_or_create_from_file(file, user)
    file.rewind if file.eof?
    file_data = file.read
    if file_data.length == 0
      Rails.logger.error "The specified image file #{file.inspect} is empty and cannot be processed."
      return nil
    end

    # read and resize the image, unless it's a pdf
    if file.content_type == 'application/pdf'
      data = file_data
    else
      magick = Magick::Image.from_blob(file_data).first
      scaled_magick = magick.resize_to_fit MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT
      data =    scaled_magick.to_blob
    end

    # see if the image is already present in the database
    hash_id = hash_id(data)
    image = find_by(hash_id: hash_id, owner_id: user.id)

    # create the image record if it doesn't exist
    unless image
      image_binary = ImageBinary.create!(data: data)
      image = create!(owner: user,
                      image_binary: image_binary,
                      hash_id: hash_id,
                      mime_type: file.content_type)
    end

    image
  end

  def can_be_viewed_by?(user)
    return true if owner_id == user.id && references.any?{|r| r.visible_to_owner?}
    references.any?{|r| r.visible_to_public?}
  end

  private

  def reference_collections
    [bios, cover_of_book_versions, sample_of_book_versions, reward_photos]
  end

  def references
    Enumerator::Lazy.new(reference_collections) do |yielder, collection|
      collection.each do |reference|
        yielder << reference
      end
    end
  end
end
