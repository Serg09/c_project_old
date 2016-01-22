namespace :seed do

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  desc 'Create a certain number of inquiries. (COUNT=10)'
  task inquiries: :environment do
    count = (ENV['COUNT'] || 10).to_i
    logger.info "creating #{count} inquiries"
    (0..count).each do
      i = FactoryGirl.create(:inquiry)
      logger.debug "created #{i.inspect}"
    end
  end
end
