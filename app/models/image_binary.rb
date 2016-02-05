# == Schema Information
#
# Table name: image_binaries
#
#  id         :integer          not null, primary key
#  data       :binary           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ImageBinary < ActiveRecord::Base
  validates_presence_of :data
end
