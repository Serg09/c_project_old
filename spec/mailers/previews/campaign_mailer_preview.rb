# Preview all emails at http://localhost:3000/rails/mailers/campaign_mailer
class CampaignMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/campaign_mailer/collecting
  def collecting
    campaign = Campaign.collecting.first || FactoryGirl.create(:collecting_campaign)
    CampaignMailer.collecting campaign
  end

  # Preview this email at http://localhost:3000/rails/mailers/campaign_mailer/cancelled
  def cancelled
    campaign = Campaign.cancelled.first || FactoryGirl.create(:cancelled_campaign)
    CampaignMailer.cancelled campaign
  end

  def succeeded
    campaign = Campaign.cancelled.first || FactoryGirl.create(:cancelled_campaign)
    CampaignMailer.succeeded(campaign)
  end

  def succeeded_notify_admin
    campaign = Campaign.cancelled.first || FactoryGirl.create(:cancelled_campaign)
    CampaignMailer.succeeded_notify_admin(campaign)
  end

  # Preview this email at http://localhost:3000/rails/mailers/campaign_mailer/collection_complete
  def collection_complete
    campaign = Campaign.collected.first || FactoryGirl.create(:collected_campaign)
    CampaignMailer.collection_complete campaign
  end

end
