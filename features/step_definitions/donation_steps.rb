Given /^the campaign for the (#{BOOK}) has received the following donations$/ do |book, table|
  campaign = book.campaigns.first
  table.hashes.each do |hash|
    FactoryGirl.create(:donation, campaign: campaign,
                                  email: hash['Email'],
                                  amount: hash['Amount'],
                                  created_at: Chronic.parse(hash['Date']))
  end
end
