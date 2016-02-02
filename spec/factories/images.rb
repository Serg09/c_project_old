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

FactoryGirl.define do
  factory :image do
    author_id 1
image_binary_id 1
hash_id "MyString"
mime_type "MyString"
  end

end
