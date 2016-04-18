if ENV['REDISCLOUD_URL'].present?

  Rails.logger.debug "Using specified redis URL #{ENV['REDISCLOUD_URL']}"

  $redis = Redis.new(url: ENV['REDISCLOUD_URL'])
else
  Rails.logger.debug "Using default redis configuration"
end
