Given /^the (#{CAMPAIGN}) has the following rewards$/ do |campaign, table|
  keys = table.raw.first.map{|key| key.parameterize.underscore.to_sym}
  table.raw.drop(1).each do |row|
    values = Hash[keys.zip(row)]
    FactoryGirl.create(:reward, values.merge(campaign: campaign))
  end
end
