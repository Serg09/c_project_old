Given /^there is an (?:author|user) named "(\S+) ([^"]+)" with email address "([^"]+)"$/ do |first_name, last_name, email|
  FactoryGirl.create(:approved_user, first_name: first_name, last_name: last_name, email: email)
end

When /^an administrator approves the account for (#{USER})$/ do |user|
  user.status = User.APPROVED
  user.save!
  # Doing this here as it will be the controller that handles this
  # in production and this is easier than recreating the web steps
  # to similate the approval for the sake of the test
  UserMailer.account_approved_notification(user).deliver_now
end

When /^an administrator rejects the account for (#{USER})$/ do |user|
  user.status = User.REJECTED
  user.save!
  # Doing this here as it will be the controller that handles this
  # in production and this is easier than recreating the web steps
  # to similate the approval for the sake of the test
  UserMailer.account_rejected_notification(user).deliver_now
end

Given /^there is an? (?:(rejected|approved|pending) )?(?:author|user) with email (?:address )?"([^"]+)" and password "([^"]+)"$/ do |status, email, password|
  status ||= User.APPROVED
  FactoryGirl.create(:user, email: email,
                              password: password,
                              password_confirmation: password,
                              status: status)
end

Given /^there is an? (?:(rejected|accepted|pending) )?(?:author|user) named "([^"]+)" with email "([^"]+)" submitted on (#{DATE})$/ do |status, full_name, email, created_at|
  match = /(\w+)\s(\w+)/.match(full_name)
  expect(match).not_to be_nil
  first_name = match[1]
  last_name = match[2]
  status ||= User.APPROVED
  FactoryGirl.create(:user, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              status: status.strip,
                              created_at: created_at)
end

Given /^there is an (?:author|user) named "([\S]+)\s([^"]+)" with email "([^"]+)" and password "([^"]+)"$/ do |first_name, last_name, email, password|
  FactoryGirl.create(:user, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              password: password,
                              password_confirmation: password)
end

Given /^I am signed in as an (?:author|user) with "([^\/]+)\/([^"]+)"$/ do |email, password|
  visit new_user_session_path
  within('#main_content') do
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
  end
  within('#top_bar') do
    expect(page).to have_content ('Sign out')
  end
end
