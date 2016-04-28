# Resque worker class that sends campaign
# progress notifications
class CampaignProgressNotifier
  @queue = :normal

  def self.perform
    Rails.logger.info "Start sending campaign progress notifications."
    Campaign.send_progress_notifications
    Rails.logger.info "Done sending campaign progress notifications."
  end
end
