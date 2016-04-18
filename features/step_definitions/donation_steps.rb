Given /^the (#{CAMPAIGN}) has received the following donations$/ do |campaign, table|
  keys = table.raw.first.map{|key| key.parameterize.underscore.to_sym}
  table.raw.drop(1).each do |hash|
    values = Hash[keys.zip(hash)]

    reward_description = values.delete(:reward)
    if reward_description.present?
      reward = campaign.rewards.find_by(description: reward_description)
      expect(reward).not_to be_nil
      values[:reward_id] = reward.id
    end

    created_at = values.delete(:date)
    if created_at.present?
      values[:created_at] = Chronic.parse(created_at)
    end
    donation = FactoryGirl.create(:donation, values.merge(campaign: campaign))
    FactoryGirl.create(:payment, donation: donation)
  end
end
