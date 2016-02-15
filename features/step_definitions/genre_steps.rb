Given /^the following genres are available$/ do |table|
  table.raw.each do |row|
    Genre.create! name: row.first
  end
end
