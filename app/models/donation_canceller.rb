class DonationCanceller
  @queue = :donation_cancellation

  def self.perform(campaign_id, attempt_number = 1)
  end
end
