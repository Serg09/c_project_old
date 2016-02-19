# == Schema Information
#
# Table name: images
#
#  id              :integer          not null, primary key
#  author_id       :integer          not null
#  image_binary_id :integer          not null
#  hash_id         :string(40)       not null
#  mime_type       :string(20)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Image < ActiveRecord::Base
  MAX_IMAGE_WIDTH = 1024
  MAX_IMAGE_HEIGHT = 1024

  belongs_to :author
  belongs_to :image_binary
  has_many :bios, foreign_key: 'photo_id'
  has_many :cover_of_books, foreign_key: 'cover_image_id', class_name: 'Book'
  has_many :sample_of_books, foreign_key: 'sample_id', class_name: 'Book'

  validates_presence_of :author_id, :image_binary_id, :hash_id
  validates_length_of :hash_id, is: 40
  validates_uniqueness_of :hash_id

  def self.hash_id(data)
    Digest::SHA1.hexdigest(data)
  end

  def self.find_or_create_from_file(file, author)
    # read and resize the image
    magick = Magick::Image.from_blob(file.read).first
    scaled_magick = magick.resize_to_fit MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT
    data = scaled_magick.to_blob

    # see if the image is already present in the database
    hash_id = hash_id(data)
    image = find_by(hash_id: hash_id, author_id: author.id)

    # create the image record if it doesn't exist
    unless image
      image_binary = ImageBinary.create!(data: data)
      image = create!(author: author,
                      image_binary: image_binary,
                      hash_id: hash_id,
                      mime_type: file.respond_to?(:content_type) ?
                        file.content_type :
                        'image/jpeg')

    end

    image
  end

  def can_be_viewed_by?(author)
    return true if author_id == author.id && references.any?{|r| r.pending?}
    references.any?{|r| r.approved?}
  end

  private

  def reference_collections
    [bios, cover_of_books, sample_of_books]
  end

  def references
    Enumerator::Lazy.new(reference_collections) do |yielder, collection|
      collection.each do |reference|
        yielder << reference
      end
    end
  end
end
