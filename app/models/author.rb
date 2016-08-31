class Author < ActiveRecord::Base
  validates_presence_of :first_name, :last_name
  validates_length_of [:first_name, :last_name], maximum: 100
  validates_uniqueness_of :first_name, scope: :last_name
end
