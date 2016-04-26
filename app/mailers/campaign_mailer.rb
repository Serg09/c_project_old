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
    mail to: campaign.book.author.email, subject: 'Campaign donation collection complete'
  end

  def succeeded(campaign)
    inline_images
    @campaign = campaign
    subject = "Your campaign for #{@campaign.book.administrative_title} has reached its goal!"
    mail to: campaign.book.author.email, subject: subject
  end

  def succeeded_notify_admin(campaign)
    inline_images
    @campaign = campaign
    subject = "The campaign for #{@campaign.book.administrative_title} has reached its goal!"
    mail to: 'info@crowdscribed.com', subject: subject
  end
end
