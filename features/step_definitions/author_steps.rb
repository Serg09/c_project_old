AUTHOR = Transform /author (.+@.+)/ do |email|
  nil
end

When /^an administrator approves the account for (#{AUTHOR})$/ do |author|
  pending "Need to implement this step"
end
