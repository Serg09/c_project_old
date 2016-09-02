When /^an administrator has approved the bio for (#{USER})$/ do |user|
  expect(user.pending_bio).not_to be_nil
  user.pending_bio.approve!
end

Given /^(#{USER}) submitted the following bio on (#{DATE})$/ do |user, date, table|
  values = table.raw.reduce({}) do |hash, row|
    key = row[0].downcase.to_sym
    hash[key] = row[1]
    hash
  end
  FactoryGirl.create(:bio, author: user,
                           created_at: date,
                           text: values[:text])
end

Given /^(#{USER}) has an approved bio$/ do |user|
  FactoryGirl.create(:approved_bio, author: user)
end

Given /^(#{AUTHOR}) has a bio$/ do |author|
  FactoryGirl.create(:approved_bio, author: author)
end
