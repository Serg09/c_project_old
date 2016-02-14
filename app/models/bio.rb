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
  include Approvable

  before_save :process_photo_file

  belongs_to :author
  belongs_to :photo, class_name: Image
  validates_associated :links
  serialize :links, Link
  validates_presence_of :author_id, :text
  
  attr_accessor :photo_file

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

  def process_photo_file
    return unless photo_file

    image = Image.find_or_create_from_file(photo_file, author)
    self.photo_id = image.id
  end
end
