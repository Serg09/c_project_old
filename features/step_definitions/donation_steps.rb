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
    name_string = values.delete(:name)

    donation = FactoryGirl.create(:donation, values.merge(campaign: campaign))

    address = address_string.present? ? parse_address(address_string) : {}
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
      name = name_string.present? ?
        /\A(?<first_name>\S+) (?<last_name>.*)\z/.match(name_string) :
        {first_name: Faker::Name.first_name,
         last_name: Faker::Name.last_name}

      if reward.physical_address_required?
        FactoryGirl.create(:physical_fulfillment, donation: donation,
                                                  reward: reward,
                                                  first_name: name[:first_name],
                                                  last_name: name[:last_name],
                                                  address1: address[:line1],
                                                  address2: address[:line2],
                                                  city: address[:city],
                                                  state: address[:state],
                                                  postal_code: address[:postal_code])
      else
        FactoryGirl.create(:electronic_fulfillment, donation: donation,
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
  visit new_campaign_donation_path(campaign)
  within('#main_content') do
    fill_in 'Amount', with: amount.to_s
    fill_in 'Credit card', with: Faker::Business.credit_card_number.gsub(/\D/, '')
    fill_in 'CVV', with: Faker::Number.number(3).to_s
    fill_in 'Email', with: Faker::Internet.email
    fill_in 'First name', with: Faker::Name.first_name
    fill_in 'Last name', with: Faker::Name.last_name
    fill_in 'Address', with: Faker::Address.street_address
    fill_in 'Line 2', with: Faker::Address.secondary_address
    fill_in 'City', with: Faker::Address.city
    fill_in 'State', with: Faker::Address.state_abbr
    fill_in 'Postal code', with: Faker::Address.postcode
    click_button 'Submit'
  end
end
