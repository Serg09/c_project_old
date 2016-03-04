When /^an administrator approves the account for (#{AUTHOR})$/ do |author|
  author.status = Author.APPROVED
  author.save!
  # Doing this here as it will be the controller that handles this
  # in production and this is easier than recreating the web steps
  # to similate the approval for the sake of the test
  AuthorMailer.account_approved_notification(author).deliver_now
end

When /^an administrator rejects the account for (#{AUTHOR})$/ do |author|
  author.status = Author.REJECTED
  author.save!
  # Doing this here as it will be the controller that handles this
  # in production and this is easier than recreating the web steps
  # to similate the approval for the sake of the test
  AuthorMailer.account_rejected_notification(author).deliver_now
end

Given /^there is an? (?:(rejected|accepted|pending) )?author with email (?:address )?"([^"]+)" and password "([^"]+)"$/ do |status, email, password|
  status ||= Author.APPROVED
  FactoryGirl.create(:author, email: email,
                              password: password,
                              password_confirmation: password,
                              status: status)
end

Given /^there is an? (?:(rejected|accepted|pending) )?author named "([^"]+)" with email "([^"]+)" submitted on (#{DATE})$/ do |status, full_name, email, created_at|
  match = /(\w+)\s(\w+)/.match(full_name)
  expect(match).not_to be_nil
  first_name = match[1]
  last_name = match[2]
  status ||= Author.APPROVED
  FactoryGirl.create(:author, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              status: status.strip,
                              created_at: created_at)
end

Given /^there is an author named "([\S]+)\s([^"]+)" with email "([^"]+)" and password "([^"]+)"$/ do |first_name, last_name, email, password|
  FactoryGirl.create(:author, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              password: password,
                              password_confirmation: password)
end

Given /^I am signed in as an author with "([^\/]+)\/([^"]+)"$/ do |email, password|
  visit new_author_session_path
  within('#main_content') do
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
  end
  within('#top_bar') do
    expect(page).to have_content ('Sign out')
  end
end
