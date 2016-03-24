Given /^there are the following house rewards$/ do |table|
  keys = table.raw.first.map{|k| k.parameterize.underscore}
  table.raw.drop(1).each do |row|
    values = Hash[keys.zip(row)]
    FactoryGirl.create(:house_reward, values)
  end
end
