FactoryGirl.define do
  factory :book, aliases: [:approved_book] do
    association :author, factory: :approved_author
    title { Faker::Book.title }
    short_description { Faker::Hipster.sentence(3) }
    long_description { Faker::Hipster.paragraphs.join("\n") }
    status 'approved'

    factory :pending_book do
      status 'pending'
    end

    factory :rejected_book do
      status 'rejected'
    end
  end
end
