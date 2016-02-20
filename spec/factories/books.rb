FactoryGirl.define do
  factory :book do
    association :author, factory: :approved_author
  end
end
