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

  before_save :process_cover_image_file, :process_sample_file

  validates_presence_of :book, :title, :short_description
  validates :title, length: { maximum: 255 }
  validates :short_description, length: { maximum: 1000 }
  validate :sample_file, :must_be_pdf
  validate :cover_image_file, :must_be_image
  validate :genres, :cannot_have_more_than_3

  attr_accessor :cover_image_file, :sample_file
  delegate :author, :active_campaign, to: :book

  def long_or_short_description
    long_description.present? ? long_description : short_description
  end

  def new_copy
    result = book.versions.new
    [:title,
     :short_description,
     :long_description,
     :cover_image_id,
     :sample_id].each do |field|
       result.send("#{field}=", self.send(field))
     end
     genres.each{|g| result.genres << g}
     result
  end

  private

  def cannot_have_more_than_3
    errors.add(:genres, 'cannot have more than three selections') if genres.to_a.count > 3
  end

  def pdf?(file)
    file.content_type == 'application/pdf'
  end

  def must_be_pdf
    if sample_file.present? && !pdf?(sample_file)
      errors.add(:sample_file, "must be a PDF")
    end
  end

  IMAGE_PATTERN = /\.(?:jpe?g|png|gif)$/

  def image?(file)
    (file.respond_to?(:content_type) && file.content_type.start_with?("image")) ||
      (file.respond_to?(:extname) && !!(IMAGE_PATTERN =~ file.extname))
  end

  def must_be_image
    if cover_image_file.present? && !image?(cover_image_file)
      errors.add(:cover_image_file, "must be an image")
    end
  end

  def process_cover_image_file
    return unless cover_image_file

    image = Image.find_or_create_from_file(cover_image_file, author)
    self.cover_image_id = image.id if image
  end

  def process_sample_file
    return unless sample_file

    image = Image.find_or_create_from_file(sample_file, author)
    self.sample_id = image.id if image
  end

  def current_version
    book.approved_version
  end
end
