When /^I am on the (.*)$/ do |identifier|
  visit path_for(identifier)
end

When /^I fill in "([^"]+)" with "([^"]+)"$/ do |locator, content|
  fill_in locator, with: content
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
