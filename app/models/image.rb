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
  belongs_to :author
  belongs_to :image_binary

  validates_presence_of :author_id, :image_binary_id, :hash_id
  validates_length_of :hash_id, is: 40
  validates_uniqueness_of :hash_id

  def self.hash_id(data)
    Digest::SHA1.hexdigest(data)
  end
end
