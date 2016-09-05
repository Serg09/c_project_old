FactoryGirl.define do
  factory :book_version, aliases: [:approved_book_version] do
    transient do
      genres []
    end
    book
    title { Faker::Book.title }
    short_description { Faker::Hipster.sentence(3) }
    long_description { Faker::Hipster.paragraphs.join("\n") }
    status 'approved'

    before(:create) do |book_version, evaluator|
      evaluator.genres.each do |genre|
        book_version.genres << genre
      end
    end

    factory :pending_book_version do
      status 'pending'
    end

    factory :rejected_book_version do
      status 'rejected'
      comments { Faker::Lorem.paragraph(1) }
    end
  end
end
