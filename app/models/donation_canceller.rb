class DonationCanceller
  @queue = :donation_cancellation

  def self.perform(campaign_id, attempt_number = 1)
    Rails.logger.info "Cancelling donations for campaign #{campaign_id}"

    campaign = Campaign.find(campaign_id)
    unless campaign.cancel_donations
      if attempt_number < maximum_attempt_count
        Rails.logger.warn "At least one donation could not be cancelled for campaign #{campaign_id}. Trying again at #{2.hours.from_now}."
        Resque.enqueue_in 2.hours, DonationCanceller, campaign_id, attempt_number + 1
      else
        Rails.logger.warn "At least one donation could not be collected for campaign #{campaign_id}. The maximum number of retries has been reached. The cancellation is being finalized now."
        campaign.finalize_cancellation
      end
    end
    Rails.logger.info "Completed donation cancellation for campaign #{campaign_id}."
  rescue Exceptions::InvalidCampaignStateError
    Rails.logger.warn "Campaign #{campaign_id} is currently in the state #{campaign.state}, so donations will not be cancelled."
  rescue => e
    Rails.logger.error "Unable to complete the cancellation for campaign #{campaign_id}, #{e.message}, #{e.backtrace.join("\n  ")}"
  end

  def self.maximum_attempt_count
    3
  end
end
