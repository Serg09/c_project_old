Given /^there is an author named "(\S+) ([^"]+)"$/ do |first_name, last_name|
  author = FactoryGirl.create(:author, first_name: first_name, last_name: last_name)
end

