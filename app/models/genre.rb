# == Schema Information
#
# Table name: genres
#
#  id         :integer          not null, primary key
#  name       :string(50)       not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Genre < ActiveRecord::Base
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: 50 }

  has_and_belongs_to_many :book_versions

  scope :alphabetized, ->{order(:name)}
end
