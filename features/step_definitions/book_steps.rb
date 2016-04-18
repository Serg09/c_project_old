Given /^(#{AUTHOR}) submitted a book titled "([^"]+)" on (#{DATE})$/ do |author, title, date|
  FactoryGirl.create(:pending_book, author: author, title: title, created_at: date)
end

Given /^(#{AUTHOR}) has an approved book titled "([^"]+)"$/ do |author, title|
  FactoryGirl.create(:approved_book, author: author, title: title)
end

Given /^(#{AUTHOR}) has a book titled "([^"]+)"$/ do |author, title|
  FactoryGirl.create(:approved_book, author: author, title: title)
end

Given /^there is a book titled "([^"]+)"$/ do |title|
  FactoryGirl.create(:approved_book, title: title)
end

Given /^authors have submitted the following books$/ do |table|
  keys = table.raw.first.map{|key| key.downcase.underscore.to_sym}
  table.raw.lazy.drop(1).map do |attr|
    Hash[*keys.zip(attr).flatten]
  end.each do |book_attributes|
    author = find_or_create_author_by_full_name(book_attributes[:author])
    book = FactoryGirl.create(:approved_book, book_attributes.merge(author: author))
  end
end

Then /^I should see the following books$/ do |expected_table|
  actual_table = all(:css, '.book').map do |element|
    author, title = ['.author', '.title'].map{|id| element.find(id).text.strip}
    {'Author' => author, 'Title' => title}
  end
  expected_table.diff!(actual_table)
end
