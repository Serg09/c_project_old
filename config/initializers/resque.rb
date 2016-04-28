if ENV['REDISCLOUD_URL'].present?
  $redis = Resque.redis = Redis.new(url: ENV['REDISCLOUD_URL'])
end

Resque.schedule = YAML.load_file(Rails.root.join('config', 'resque_schedule.yml'))
