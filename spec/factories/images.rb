FactoryGirl.define do
  factory :image do
    author
    image_binary
    hash_id { Image.hash_id Faker::Hipster.word }
    mime_type 'image/jpeg'
  end
end
