class Genre < ActiveRecord::Base
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: 50 }

  has_and_belongs_to_many :book_versions

  scope :alphabetized, ->{order(:name)}
end
