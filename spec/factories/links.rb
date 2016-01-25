FactoryGirl.define do
  factory :link do
    bio
    site 'facebook'
    url { Faker::Internet.url('facebook.com') }
  end
end
