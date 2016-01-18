Given /^there is an administrator with email "([^"]+)" and password "([^"]+)"$/ do |email, password|
  Administrator.create! email: email, password: password, password_confirmation: password
end

Given /^I am signed in as an administrator with "([^\/]+)\/([^"]+)"$/ do |email, password|
  visit new_administrator_session_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_on 'Sign in'
  within('#main-menu') do
    expect(page).to have_content('Sign out')
  end
end
