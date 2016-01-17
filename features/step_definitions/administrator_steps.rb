Given /^there is an administrator with email "([^"]+)" and password "([^"]+)"$/ do |email, password|
  Administrator.create! email: email, password: password, password_confirmation: password
end
