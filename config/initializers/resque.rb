if ENV['REDISCLOUD_URL'].present?
  Resque.redis = Redis.new(url: ENV['REDISCLOUD_URL'])
end
