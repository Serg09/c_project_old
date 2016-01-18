AUTHOR = Transform /author (.+@.+)/ do |email|
  author = Author.find_by(email: email)
  expect(author).not_to be_nil
  author
end

DATE = Transform /(\d{1,2})\/(\d{1,2})\/(\d{4})/ do |month, date, year|
  Date.new(year.to_i, month.to_i, date.to_i)
end

When /^an administrator approves the account for (#{AUTHOR})$/ do |author|
  author.status = Author.accepted
  author.save!
  # Doing this here as it will be the controller that handles this
  # in production and this is easier than recreating the web steps
  # to similate the approval for the sake of the test
  AuthorMailer.account_approved_notification(author).deliver_now
end

When /^an administrator rejects the account for (#{AUTHOR})$/ do |author|
  author.status = Author.rejected
  author.save!
  # Doing this here as it will be the controller that handles this
  # in production and this is easier than recreating the web steps
  # to similate the approval for the sake of the test
  AuthorMailer.account_rejected_notification(author).deliver_now
end

Given /^there is a pending author named "([^"]+)" with email "([^"]+)" submitted on (#{DATE})$/ do |full_name, email, created_at|
  match = /(\w+)\s(\w+)/.match(full_name)
  expect(match).not_to be_nil
  first_name = match[1]
  last_name = match[2]
  FactoryGirl.create(:author, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              created_at: created_at)
end
