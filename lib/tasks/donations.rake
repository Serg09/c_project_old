namespace :donations do
  desc 'Refund donations for campaigns in the cancelling state'
  task refund: :environment do
    Campaign.cancelling.each do |campaign|
      puts "Cancelling campaign #{campaign.id} for #{campaign.book.administrative_title}"
      begin
        campaign.donations.collected.each do |donation|
          donation.cancel
        end
        campaign.finalize_cancellation
      rescue => e
        puts "unable to cancel donations for #{campaign.id}"
      end
    end
  end
end
