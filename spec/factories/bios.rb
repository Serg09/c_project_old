FactoryGirl.define do
  factory :bio, aliases: [:pending_bio] do
    association :author, factory: :user
    text { Faker::Lorem.paragraphs(3).join("\n")}

    factory :approved_bio do
      status 'approved'
    end

    factory :rejected_bio do
      status 'rejected'
    end

    factory :superseded_bio do
      status 'superseded'
    end
  end
end
