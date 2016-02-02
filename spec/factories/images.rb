FactoryGirl.define do
  factory :image do
    author
    image_binary
    hash_id { Image.hash_id image_binary.data }
    mime_type 'image/jpeg'
  end
end
