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

  def progress(campaign)
    inline_images
    @campaign = campaign
    @unsubscribe_url = unsubscribe_user_url(campaign.book.author)
    subject = "Campaign progress: #{@campaign.book.approved_version.title}"
    mail to: campaign.author.email, subject: subject
  end
end
