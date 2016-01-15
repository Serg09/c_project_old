AUTHOR = Transform /author (.+@.+)/ do |email|
  author = Author.find_by(email: email)
  expect(author).not_to be_nil
  author
end

When /^an administrator approves the account for (#{AUTHOR})$/ do |author|
  author.status = Author.accepted
  author.save!
end
