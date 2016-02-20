FactoryGirl.define do
  factory :book_version, aliases: [:approved_book_version] do
    book
    title { Faker::Book.title }
    short_description { Faker::Hipster.sentence(3) }
    long_description { Faker::Hipster.paragraphs.join("\n") }
    status 'approved'

    factory :pending_book_version do
      status 'pending'
    end

    factory :rejected_book_version do
      status 'rejected'
    end
  end
end
