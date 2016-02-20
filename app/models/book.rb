# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  author_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Book < ActiveRecord::Base
  belongs_to :author
  validates_presence_of :author_id
  has_many :versions, class_name: 'BookVersion'
end
