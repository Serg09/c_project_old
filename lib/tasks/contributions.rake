namespace :contributions do
  desc 'Refund contributions for campaigns in the cancelling state'
  task refund: :environment do
    Campaign.cancelling.each do |campaign|
      puts "Cancelling campaign #{campaign.id} for #{campaign.book.administrative_title}"
      begin
        campaign.contributions.collected.each do |contribution|
          contribution.cancel
        end
        campaign.finalize_cancellation
      rescue => e
        puts "unable to cancel contributions for #{campaign.id}"
      end
    end
  end
end
