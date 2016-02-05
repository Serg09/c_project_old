FactoryGirl.define do
  factory :image_binary do
    data { Rails.root.join('spec', 'fixtures', 'files', 'author_photo.jpg').read }
  end
end
