# == Schema Information
#
# Table name: image_binaries
#
#  id         :integer          not null, primary key
#  data       :binary           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :image_binary do
    data { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg').read }
  end

end
