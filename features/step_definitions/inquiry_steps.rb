Given /user "(\w+) (\w+)" with email "([^"]+)" has submitted an inquiry asking "([^"]+)" at (#{DATE_TIME})/ do |first_name, last_name, email, body, created_at|
  result = Inquiry.create!(first_name: first_name,
                  last_name: last_name,
                  email: email,
                  body: body,
                  created_at: created_at)
end
