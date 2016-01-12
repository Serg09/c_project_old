When /^I am on (.*)$/ do |identifier|
  visit path_for(identifier)
end

When /^I fill in "([^"]+)" with "([^"]+)"$/ do |locator, content|
  fill_in locator, with: content
end

When /^I select "([^"]+)" from "([^"]+)"$/ do |value, locator|
  select value, from: locator
end

When /^I check "([^"]+)"$/ do |locator|
  check locator
end

When /^I click "([^"]+)"$/ do |locator|
  click_on locator
end

Then /^(.*) within (.*)$/ do |step_content, context|
  locator = locator_for context
  within(locator){step(step_content)}
end

Then /^I should see "([^"]+)"$/ do |content|
  expect(page).to have_content(content)
end
