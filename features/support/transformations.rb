DATE = Transform /(\d{1,2})\/(\d{1,2})\/(\d{4})/ do |month, date, year|
  Date.new(year.to_i, month.to_i, date.to_i)
end

DATE_TIME = Transform /(\d{1,2}):(\d{2}) (AM|PM) on (\d{1,2})\/(\d{1,2})\/(\d{4})/ do |hour, minute, am_pm, month, date, year|
  hour_offset = am_pm.upcase == "AM" ? 0 : 12
  DateTime.new(year.to_i, month.to_i, date.to_i, hour.to_i + hour_offset, minute.to_i)
end
