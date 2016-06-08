When /^I am on (.*)$/ do |identifier|
  visit path_for(identifier)
end

When /^I fill in "([^"]+)" with "([^"]+)"$/ do |locator, content|
  fill_in locator, with: content
end

When /^I select "([^"]+)" from "([^"]+)"$/ do |value, locator|
  select value, from: locator
end

When /^I select the "([^"]+)" option$/ do |locator|
  page.choose(locator)
end

When /^I check "([^"]+)"(?: and "([^"]+)")?$/ do |locator1, locator2|
  check locator1
  check locator2 if locator2
end

When /^I click "([^"]+)"$/ do |locator|
  click_on locator
end

When /^I click the (.*) button$/ do |button_name|
  locator = ".#{hyphenize(button_name)}-button"
  node = page.find(locator)
  node.click
end

Then /^(.*) within (.*)$/ do |step_content, context|
  locator = locator_for context
  within(locator){step(step_content)}
end

Then /^I should see "([^"]+)"$/ do |content|
  expect(page).to have_content(content)
end

Then /^I should see a (.*) button$/ do |button_name|
  locator = ".#{hyphenize(button_name)}-button"
  page.assert_selector(locator)
end

Then /^I should not see a (.*) button$/ do |button_name|
  locator = ".#{hyphenize(button_name)}-button"
  page.assert_no_selector(locator)
end

Then /^I should see the following (.*) table$/ do |description, expected_table|
  id = "##{description_to_id(description)}-table"
  html_table = find(id)
  actual_table = parse_table(html_table)
  expected_table.diff!(actual_table)
end

Then /^I should see the following (.*) records$/ do |description, expected_table|
  locator = description.gsub(' ', '_')
  actual_table = parse_records(all(locator))
  expected_table.diff!(actual_table)
end

When /^I select (?:the )?file "([^"]+)" for "([^"]+)"$/ do |file_name, locator|
  attach_file(locator, Rails.root.join('features', 'resources', file_name))
end

Given /^(?:today|it) is (#{DATE})$/ do |date|
  date_time_string = "#{date} 12:00:00 Central (US & Canada)"
  date_time = Chronic.parse(date_time_string)
  Timecop.freeze(date_time)
end

Then /^print the contents of the (.*) table$/ do |table_identifier|
  table_name = table_identifier.parameterize.pluralize
  rows = ActiveRecord::Base.connection.execute("select * from #{table_name}")
  rows.each do |row|
    puts row.inspect
  end
end
