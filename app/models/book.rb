# == Schema Information
#
# Table name: books
#
#  id                :integer          not null, primary key
#  author_id         :integer          not null
#  title             :string(255)      not null
#  short_description :string(1000)     not null
#  long_description  :text
#  cover_image_id    :integer
#  status            :string           default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Book < ActiveRecord::Base
  belongs_to :author

  before_save :process_cover_image_file

  validates_presence_of :author_id, :title, :short_description
  validates :title, length: { maximum: 255 }
  validates :short_description, length: { maximum: 1000 }

  attr_accessor :cover_image_file

  private

  def process_cover_image_file
    return unless cover_image_file

    image = Image.find_or_create_from_file(cover_image_file, author)
    self.cover_image_id = image.id
  end
end
