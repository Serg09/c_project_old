FactoryGirl.define do
  factory :payment do
    donation donation
    external_id "PAY-17S8410768582940NKEE66EQ"
    state "approved"
    content { {id: "PAY-17S8410768582940NKEE66EQ"}.to_json }
  end
end
