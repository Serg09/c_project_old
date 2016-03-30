Given /^the campaign for the (#{BOOK}) has received the following donations$/ do |book, table|
  campaign = book.campaigns.first
  table.hashes.each do |hash|
    reward_description = hash.delete('Reward')
    if reward_description.present?
      reward = Reward.find_by(description: reward_description)
      expect(reward).not_to be_nil
      reward_id = reward.id
    else
      reward_id = nil
    end
    FactoryGirl.create(:donation, campaign: campaign,
                                  reward_id: reward_id,
                                  email: hash['Email'],
                                  amount: hash['Amount'],
                                  created_at: Chronic.parse(hash['Date']))
  end
end
