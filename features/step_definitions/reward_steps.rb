Given /^the (#{CAMPAIGN}) has the following rewards$/ do |campaign, table|
  keys = table.raw.first.map{|key| key.parameterize.underscore.to_sym}
  table.raw.drop(1).each do |row|
    values = Hash[keys.zip(row)]
    house_reward = values.delete(:house_reward)
    if house_reward.present?
      record = HouseReward.find_by(description: house_reward)
      expect(record).not_to be_nil
      values[:house_reward_id] = record.id
    end
    FactoryGirl.create(:reward, values.merge(campaign: campaign))
  end
end
