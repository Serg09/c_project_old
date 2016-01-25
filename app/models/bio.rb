class Bio < ActiveRecord::Base
  belongs_to :author
  validates_presence_of :author_id, :text
end
