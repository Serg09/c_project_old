FactoryGirl.define do
  factory :bio, aliases: [:pending_bio] do
    author
    text { Faker::Lorem.paragraph(1) }

    factory :approved_bio do
      status Bio.APPROVED
    end

    factory :rejected_bio do
      status Bio.REJECTED
    end
  end
end
