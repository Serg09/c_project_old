Given /^(#{AUTHOR}) submitted a book titled "([^"]+)" on (#{DATE})$/ do |author, title, date|
  FactoryGirl.create(:pending_book, author: author, title: title, created_at: date)
end
