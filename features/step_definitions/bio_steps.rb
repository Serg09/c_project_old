When /^an administrator has approved the bio for (#{AUTHOR})$/ do |author|
  expect(author.pending_bio).not_to be_nil
  author.pending_bio.approve!
end

Given /^(#{AUTHOR}) submitted the following bio on (#{DATE})$/ do |author, date, table|
  values = table.raw.reduce({}) do |hash, row|
    key = row[0].downcase.to_sym
    hash[key] = row[1]
    hash
  end
  FactoryGirl.create(:bio, author: author,
                           created_at: date,
                           text: values[:text])
end

Given /^(#{AUTHOR}) has an approved bio$/ do |author|
  FactoryGirl.create(:approved_bio, author: author)
end
