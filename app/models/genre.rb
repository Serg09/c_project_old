class Genre < ActiveRecord::Base
  validates :name, presence: true,
                   uniqueness: true,
                   length: { maximum: 50 }

  has_and_belongs_to_many :books

  scope :alphabetized, ->{order(:name)}
end
