# Collects campaign donations by executing PayPal
# transactions that have already been authorized
class DonationCollector
  @queue = :donation_collection

  def self.perform(campaign_id, attempt_number = 1)
    campaign = Campaign.find(campaign_id)
    unless campaign.collect_donations
      if attempt_number < maximum_attempt_count
        Resque.enqueue_in(2.hours, DonationCollector, campaign_id, attempt_number + 1)
      else
        campaign.finalize_collection
      end
    end
    CampaignMailer.collection_complete(campaign).deliver_now if campaign.collected?
  rescue => e
    Rails.logger.error "Unable to complete the collection for campaign_id=#{campaign_id}, #{e.message}, #{e.backtrace.join("\n  ")}"
  end

  private

  def self.maximum_attempt_count
    3
  end
end
