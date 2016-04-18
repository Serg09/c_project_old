if ENV['REDISCLOUD_URL'].present?
  $redis = Resque.redis = Redis.new(url: ENV['REDISCLOUD_URL'])
end
