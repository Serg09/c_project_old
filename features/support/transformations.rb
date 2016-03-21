DATE = Transform /(\d{1,2})\/(\d{1,2})\/(\d{4})/ do |month, date, year|
  Date.new(year.to_i, month.to_i, date.to_i)
end

DATE_TIME = Transform /(\d{1,2}):(\d{2}) (AM|PM) on (\d{1,2})\/(\d{1,2})\/(\d{4})/ do |hour, minute, am_pm, month, date, year|
  hour_offset = am_pm.upcase == "AM" ? 0 : 12
  DateTime.new(year.to_i, month.to_i, date.to_i, hour.to_i + hour_offset, minute.to_i)
end

DOLLAR_AMOUNT = Transform /\$\d{1,3}(?:,\d{3})*(?:\.\d{2})?/ do |amount|
  if amount.is_a? String # this allows dollar signs in tables
    BigDecimal.new(amount.gsub(/[\$,]/, ''))
  else
    amount
  end
end

AUTHOR = Transform /author (.+@.+)/ do |email|
  author = Author.find_by(email: email)
  expect(author).not_to be_nil, "Author with email \"#{email}\" not found"
  author
end

BOOK = Transform /book "([^"]+)"/ do |title|
  book_version = BookVersion.find_by(title: title)
  expect(book_version).not_to be_nil
  book_version.book
end
