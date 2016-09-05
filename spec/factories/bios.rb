FactoryGirl.define do
  factory :bio, aliases: [:pending_bio] do
    association :author, factory: :user
    text { Faker::Lorem.paragraphs(3).join("\n")}

    factory :approved_bio do
      status 'approved'
    end

    factory :rejected_bio do
      status 'rejected'
      comments { Faker::Lorem.paragraphs(1) }
    end

    factory :superseded_bio do
      status 'superseded'
    end
  end

  factory :author_bio, class: Bio do
    association :author, factory: :author
    text { Faker::Lorem.paragraphs(3).join("\n")}
    status 'approved'
  end
end
