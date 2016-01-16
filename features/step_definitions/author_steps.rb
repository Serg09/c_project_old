AUTHOR = Transform /author (.+@.+)/ do |email|
  author = Author.find_by(email: email)
  expect(author).not_to be_nil
  author
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
