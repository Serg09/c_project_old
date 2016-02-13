FactoryGirl.define do
  factory :book, aliases: [:approved_book] do
    author
    title { Faker::Book.title }
    short_description { Faker::Hipster.sentence(3) }
    long_description { Faker::Hipster.paragraph(2) }
    status 'approved'

    factory :pending_book do
      status 'pending'
    end

    factory :rejected_book do
      status 'rejected'
    end
  end
end
