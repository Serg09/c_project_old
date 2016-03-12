FactoryGirl.define do
  factory :campaign do
    book
    target_amount 1_234
    target_date { Date.today + 30 }
    paused true
  end
end
