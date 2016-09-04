Given /^(#{USER}) submitted a book titled "([^"]+)" on (#{DATE})$/ do |user, title, date|
  FactoryGirl.create(:pending_book, author: user, title: title, created_at: date)
end

Given /^(#{USER}) has an approved book titled "([^"]+)"$/ do |user, title|
  FactoryGirl.create(:approved_book, author: user, title: title)
end

Given /^(#{USER}) has a book titled "([^"]+)"$/ do |user, title|
  FactoryGirl.create(:approved_book, author: user, title: title)
end

Given /^(#{AUTHOR}) has a book titled "([^"]+)"$/ do |author, title|
  FactoryGirl.create(:approved_book, author: author, title: title)
end

Given /^there is a book titled "([^"]+)"$/ do |title|
  FactoryGirl.create(:approved_book, title: title)
end

Given /^users have submitted the following books$/ do |table|
  keys = table.raw.first.map{|key| key.downcase.underscore.to_sym}
  table.raw.lazy.drop(1).map do |attr|
    Hash[*keys.zip(attr).flatten]
  end.each do |book_attributes|
    user = find_or_create_user_by_full_name(book_attributes[:author])
    book = FactoryGirl.create(:approved_book, book_attributes.merge(author: user))
  end
end

Then /^I should see the following books$/ do |expected_table|
  actual_table = all(:css, '.book').map do |element|
    author, title = ['.author', '.title'].map{|id| element.find(id).text.strip}
    {'Author' => author, 'Title' => title}
  end
  expected_table.diff!(actual_table)
end
