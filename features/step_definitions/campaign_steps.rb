Given /^(#{AUTHOR}) has a campaign for "([^"]+)" targeting (#{DOLLAR_AMOUNT}) by (#{DATE})$/ do |author, title, target_amount, target_date|
  book_version = author.book_versions.find_by_title(title)
  expect(book_version).not_to be_nil
  book_version.book.campaigns.create!(target_amount: target_amount, target_date: target_date)
end

Given /^(?:the )?(#{BOOK}) has a campaign targeting (#{DOLLAR_AMOUNT}) by (#{DATE})$/ do |book, target_amount, target_date|
  book.campaigns.create!(target_amount: target_amount, target_date: target_date)
end

Given /^(#{BOOK}) has an active campaign$/ do |book|
  FactoryGirl.create(:campaign, book: book)
end

When /^donation collection has finished for the (#{BOOK})$/ do |book|
  campaign = book.campaigns.collecting.first
  expect(campaign).not_to be_nil
  DonationCollector.perform campaign.id
end
