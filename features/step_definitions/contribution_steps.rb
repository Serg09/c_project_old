Given /^the (#{CAMPAIGN}) has received the following contributions$/ do |campaign, table|
  keys = table.raw.first.map{|key| key.parameterize.underscore.to_sym}
  table.raw.drop(1).each do |hash|
    values = Hash[keys.zip(hash)]

    created_at = values.delete(:date)
    if created_at.present?
      values[:created_at] = Chronic.parse(created_at)
    end
    reward_description = values.delete(:reward)
    address_string = values.delete(:address)
    name_string = values.delete(:name)

    # TODO we'll need to add support for contributions with deferred collection later
    contribution = FactoryGirl.create(:contribution, values.merge(campaign: campaign, state: 'collected'))

    address = address_string.present? ? parse_address(address_string) : {}
    FactoryGirl.create(:payment, contribution: contribution)

    if reward_description.present?
      reward = campaign.rewards.find_by(description: reward_description)
      expect(reward).not_to be_nil
      name = name_string.present? ?
        /\A(?<first_name>\S+) (?<last_name>.*)\z/.match(name_string) :
        {first_name: Faker::Name.first_name,
         last_name: Faker::Name.last_name}

      if reward.physical_address_required?
        FactoryGirl.create(:physical_fulfillment, contribution: contribution,
                                                  reward: reward,
                                                  first_name: name[:first_name],
                                                  last_name: name[:last_name],
                                                  address1: address[:line1],
                                                  address2: address[:line2],
                                                  city: address[:city],
                                                  state: address[:state],
                                                  postal_code: address[:postal_code])
      else
        FactoryGirl.create(:electronic_fulfillment, contribution: contribution,
                                                    reward: reward,
                                                    email: values[:email],
                                                    first_name: name[:first_name],
                                                    last_name: name[:last_name])
      end
    end
  end
end

When /^a user donates (#{DOLLAR_AMOUNT}) for the (#{BOOK})$/ do |amount, book|
  campaign = book.campaigns.active.first
  # by passing AJAX page details
  contribution = {
    amount: amount,
    email: Faker::Internet.email,
    nonce: Faker::Number.hexadecimal(10)
  }
  page.driver.post "/campaigns/#{campaign.id}/contributions.json", contribution: contribution
end
