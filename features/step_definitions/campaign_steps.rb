Given /^(#{USER}) has an? (.*)?campaign for "([^"]+)" targeting (#{DOLLAR_AMOUNT}) by (#{DATE})$/ do |user, state, title, target_amount, target_date|
  book_version = user.book_versions.find_by_title(title)
  expect(book_version).not_to be_nil
  state = state.present? ? state.strip : 'active'
  FactoryGirl.create(:campaign, book: book_version.book,
                                target_amount: target_amount,
                                target_date: target_date,
                                state: state)
end

Given /^(?:the )?(#{BOOK}) has an? (.*)?campaign targeting (#{DOLLAR_AMOUNT})(?: by (#{DATE}))?$/ do |book, state, target_amount, target_date|
  state = state.present? ? state.strip : 'active'
  target_date = (Date.today + 30) unless target_date.present?
  FactoryGirl.create(:campaign, book: book,
                                target_amount: target_amount,
                                target_date: target_date,
                                state: state,
                                agree_to_terms: state != 'unstarted')
end

Given /^(#{BOOK}) has an active campaign$/ do |book|
  FactoryGirl.create(:campaign, book: book)
end

Given /^(?:the )?(#{BOOK}) has a campaign$/ do |book|
  FactoryGirl.create(:campaign, book: book)
end

When /^contribution collection has finished for the (#{BOOK})$/ do |book|
  campaign = book.campaigns.collecting.first
  expect(campaign).not_to be_nil
  ContributionCollector.perform campaign.id
end

Given /(#{CAMPAIGN}) is (collected|active)/ do |campaign, state|
  campaign.update_attribute :state, state
end

Given /^notification has been sent for the success of the campaign for the (#{BOOK})$/ do |book|
  campaign = book.campaigns.first
  campaign.success_notification_sent_at = DateTime.now
  campaign.save!
end

When /^the mailer sends a campaign progress notification email to (#{USER})$/ do |user|
  book = FactoryGirl.create(:book, author: user)
  campaign = FactoryGirl.create(:campaign, book: book)
  CampaignMailer.progress(campaign).deliver_now
end
