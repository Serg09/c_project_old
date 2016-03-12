Given /^(#{AUTHOR}) has a campaign for "([^"]+)" targeting (#{DOLLAR_AMOUNT}) by (#{DATE})$/ do |author, title, target_amount, target_date|
  book_version = author.book_versions.find_by_title(title)
  expect(book_version).not_to be_nil
  book_version.book.campaigns.create!(target_amount: target_amount, target_date: target_date)
end
