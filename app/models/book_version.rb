# == Schema Information
#
# Table name: book_versions
#
#  id                :integer          not null, primary key
#  book_id           :integer          not null
#  title             :string(255)      not null
#  short_description :string(1000)     not null
#  long_description  :text
#  cover_image_id    :integer
#  sample_id         :integer
#  status            :string           default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class BookVersion < ActiveRecord::Base
  include Approvable

  belongs_to :book
  has_and_belongs_to_many :genres

  accepts_nested_attributes_for :genres

  before_save :process_cover_image_file, :process_sample_file

  validates_presence_of :book_id, :title, :short_description
  validates :title, length: { maximum: 255 }
  validates :short_description, length: { maximum: 1000 }

  attr_accessor :cover_image_file, :sample_file
  delegate :author, to: :book

  private

  def process_cover_image_file
    return unless cover_image_file

    image = Image.find_or_create_from_file(cover_image_file, author)
    self.cover_image_id = image.id
  end

  def process_sample_file
    return unless sample_file

    image = Image.find_or_create_from_file(sample_file, author)
    self.sample_id = image.id
  end
end
