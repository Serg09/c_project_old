# Collects campaign donations by executing PayPal
# transactions that have already been authorized
class DonationCollector
  @queue = :donation_collection

  def self.perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    if campaign.collect_donations
      CampaignMailer.collection_complete(campaign).deliver_now
    end
  rescue => e
    Rails.logger.error "Unable to complete the collection for campaign_id=#{campaign_id}, #{e.message}, #{e.backtrace.join("\n  ")}"
  end
end
