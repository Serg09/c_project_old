FactoryGirl.define do
  factory :book, aliases: [:approved_book] do
    transient do
      title { Faker::Book.title }
      short_description { Faker::Hipster.sentence(3) }
      long_description { Faker::Hipster.paragraphs.join("\n") }
      status BookVersion.APPROVED
    end
    association :author, factory: :approved_author

    after(:create) do |book, evaluator|
      book.versions << FactoryGirl.create(:book_version,
                                          book: book,
                                          title: evaluator.title,
                                          short_description: evaluator.short_description,
                                          long_description: evaluator.long_description,
                                          status: evaluator.status)
    end

    factory :pending_book do
      transient do
        status BookVersion.PENDING
      end
    end


    factory :rejected_book do
      transient do
        status BookVersion.REJECTED
      end
    end
  end
end
