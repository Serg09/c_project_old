class DonationCanceller
  @queue = :donation_cancellation

  def self.perform(campaign_id, attempt_number = 1)
    campaign = Campaign.find(campaign_id)
    if campaign.donations.map(&:cancel).all?
      campaign.finalize_cancellation
    else
      if attempt_number < maximum_attempt_count
        Resque.enqueue_in 2.hours, DonationCanceller, campaign_id, attempt_number + 1
      else
        campaign.finalize_cancellation
      end
    end
  end

  def self.maximum_attempt_count
    3
  end
end
