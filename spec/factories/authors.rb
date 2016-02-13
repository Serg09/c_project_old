FactoryGirl.define do
  factory :author, aliases: [:pending_author] do
    transient do
      confirmed true
    end
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { "#{first_name}.#{last_name}@#{Faker::Internet.domain_name}" }
    username { "#{last_name}#{first_name.first}" }
    phone_number { Faker::PhoneNumber.phone_number }
    password "please01"
    password_confirmation "please01"
    contactable true
    package_id 1
    status Author.PENDING

    after(:create) do |author, evaluator|
      author.confirm if evaluator.confirmed
    end

    factory :approved_author do
      status Author.APPROVED
    end

    factory :rejected_author do
      status Author.REJECTED
    end
  end
end
