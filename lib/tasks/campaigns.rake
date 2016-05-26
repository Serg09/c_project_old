namespace :campaigns do
  desc 'send campaign progress notifications'
  task progress_notifications: :environment do
    if ENV['ASYNC'] then
      Resque.enqueue CampaignProgressNotifier
    else
      CampaignProgressNotifier.perform
    end
  end
end
