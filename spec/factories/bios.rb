FactoryGirl.define do
  factory :bio, aliases: [:pending_bio] do
    association :author, factory: :approved_user
    text { Faker::Lorem.paragraphs(3).join("\n")}

    factory :approved_bio do
      status Bio.APPROVED
    end

    factory :rejected_bio do
      status Bio.REJECTED
    end
  end
end
