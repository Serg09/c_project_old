Given /^the (#{CAMPAIGN}) has received the following donations$/ do |campaign, table|
  keys = table.raw.first.map{|key| key.parameterize.underscore.to_sym}
  table.raw.drop(1).each do |hash|
    values = Hash[keys.zip(hash)]

    created_at = values.delete(:date)
    if created_at.present?
      values[:created_at] = Chronic.parse(created_at)
    end
    reward_description = values.delete(:reward)
    address_string = values.delete(:address)
    donation = FactoryGirl.create(:donation, values.merge(campaign: campaign))
    address = address_string.present? ? parse_address(address_string) : nil
    if address
      FactoryGirl.create(:payment, donation: donation,
                                   address_1: address[:line1],
                                   address_2: address[:line2],
                                   city: address[:city],
                                   state_abbr: address[:state],
                                   postal_code: address[:postal_code])
    else
      FactoryGirl.create(:payment, donation: donation)
    end

    if reward_description.present?
      reward = campaign.rewards.find_by(description: reward_description)
      expect(reward).not_to be_nil
      if reward.physical_address_required?
        if address
          FactoryGirl.create(:physical_fulfillment, donation: donation,
                                                    reward: reward,
                                                    address1: address[:line1],
                                                    address2: address[:line2],
                                                    city: address[:city],
                                                    state: address[:state],
                                                    postal_code: address[:postal_code])
        else
          FactoryGirl.create(:physical_fulfillment, donation: donation, reward: reward)
        end
      else
        FactoryGirl.create(:electronic_fulfillment, donation: donation, reward: reward)
      end
    end
  end
end
