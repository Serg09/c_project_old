Given /^(#{AUTHOR}) submitted a book titled "([^"]+)" on (#{DATE})$/ do |author, title, date|
  FactoryGirl.create(:pending_book, author: author, title: title, created_at: date)
end

Given /^(#{AUTHOR}) has an approved book titled "([^"]+)"$/ do |author, title|
  FactoryGirl.create(:approved_book, author: author, title: title)
end
