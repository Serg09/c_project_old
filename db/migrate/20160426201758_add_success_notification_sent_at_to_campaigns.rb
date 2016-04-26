class AddSuccessNotificationSentAtToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :success_notification_sent_at, :time
  end
end
