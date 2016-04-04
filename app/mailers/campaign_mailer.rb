class CampaignMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def collecting(campaign)
    inline_images
    @campaign = campaign
    mail to: campaign.book.author.email, subject: 'Campaign closed'
  end

  def cancelled(campaign)
    inline_images
    @campaign = campaign
    mail to: campaign.book.author.email, subject: 'Campaign cancelled'
  end

  def collection_complete(campaign)
    inline_images
    @campaign = campaign
    mail to: campaign.book.author.email, subject: 'Campaign collection complete'
  end
end
