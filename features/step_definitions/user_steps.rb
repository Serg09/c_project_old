Given /^there is an (author|user) named "(\S+) ([^"]+)" with email address "([^"]+)"$/ do |type, first_name, last_name, email|
  user = FactoryGirl.create(:user, first_name: first_name, last_name: last_name, email: email)
  FactoryGirl.create(:approved_bio, author: user) if type == 'author'
end

Given /^there is an? (?:author|user) with email (?:address )?"([^"]+)" and password "([^"]+)"$/ do |email, password|
  FactoryGirl.create(:user, email: email,
                              password: password,
                              password_confirmation: password)
end

Given /^there is an? (?:author|user) named "([^"]+)" with email "([^"]+)" submitted on (#{DATE})$/ do |full_name, email, created_at|
  match = /(\w+)\s(\w+)/.match(full_name)
  expect(match).not_to be_nil
  first_name = match[1]
  last_name = match[2]
  FactoryGirl.create(:user, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              created_at: created_at)
end

Given /^there is an? (?:author|user) named "([\S]+)\s([^"]+)" with email "([^"]+)" and password "([^"]+)"$/ do |first_name, last_name, email, password|
  FactoryGirl.create(:user, first_name: first_name,
                              last_name: last_name,
                              email: email,
                              password: password,
                              password_confirmation: password)
end

Given /^I am signed in as an? (?:author|user) with "([^\/]+)\/([^"]+)"$/ do |email, password|
  visit new_user_session_path
  within('#main-content') do
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
  end
  within('#top-bar') do
    expect(page).to have_content ('Sign out')
  end
end

Given /^(#{USER}) is unsubscribed$/ do |user|
  user.update_attribute :unsubscribed, true
end

Then /^(#{USER}) should be subscribed$/ do |user|
  expect(user).to be_subscribed
end

Given /^there is a user named "(\S+) ([^"]+)"$/ do |first_name, last_name|
  FactoryGirl.create(:user, first_name: first_name, last_name: last_name)
end
