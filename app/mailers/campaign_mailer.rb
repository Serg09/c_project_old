class CampaignMailer < ApplicationMailer
  default from: 'noreply@crowdscribed.com'

  def collecting(campaign)
    @campaign = campaign
    mail to: campaign.book.author.email, subject: 'Campaign closed'
  end

  def cancelled(campaign)
    @campaign = campaign
    mail to: campaign.book.author.email, subject: 'Campaign cancelled'
  end

  def collection_complete(campaign)
    @campaign = campaign
    mail to: campaign.book.author.email, subject: 'Campaign contribution collection complete'
  end

  def succeeded(campaign)
    @campaign = campaign
    subject = "Your campaign for #{@campaign.book.administrative_title} has reached its goal!"
    mail to: campaign.book.author.email, subject: subject
  end

  def progress(campaign)
    @campaign = campaign
    @unsubscribe_url = unsubscribe_url(campaign.book.author.unsubscribe_token)
    subject = "Campaign progress: #{@campaign.book.approved_version.title}"
    mail to: campaign.author.email, subject: subject
  end
end
