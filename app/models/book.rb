class Book < ActiveRecord::Base
  validates_presence_of :author_id, :title, :short_description
  validates :title, length: { maximum: 255 }
  validates :short_description, length: { maximum: 1000 }

  attr_accessor :cover_image_file
end
