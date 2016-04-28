# Collects campaign donations by executing PayPal
# transactions that have already been authorized
class DonationCollector
  @queue = :normal

  def self.perform(campaign_id, attempt_number = 1)
    Rails.logger.info "Collecting donations for campaign #{campaign_id}"

    campaign = Campaign.find(campaign_id)
    unless campaign.collect_donations
      if attempt_number < maximum_attempt_count
        Rails.logger.warn "At least one donation could not be collected for #{campaign_id}. Trying again at #{2.hours.from_now}"
        Resque.enqueue_in(2.hours, DonationCollector, campaign_id, attempt_number + 1)
      else
        Rails.logger.warn "At least one donation could not be collected for #{campaign_id}. The maximum number of retries has been reaching. Finalizing the collection now."
        campaign.finalize_collection
      end
    end
    CampaignMailer.collection_complete(campaign).deliver_now if campaign.collected?

    Rails.logger.info "Completed donation collection for campaign #{campaign_id}"
  rescue Exceptions::InvalidCampaignStateError
    Rails.logger.warn "Campaign #{campaign_id} is in state '#{campaign.state}' so donations will not be collected."
  rescue => e
    Rails.logger.error "Unable to complete the collection for campaign_id=#{campaign_id}, #{e.message}, #{e.backtrace.join("\n  ")}"
  end

  private

  def self.maximum_attempt_count
    3
  end
end
