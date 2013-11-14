Dir[File.join(Rails.root, 'lib', '*.rb')].each { |file| require file}
resque_config = YAML.load_file("#{Rails.root.to_s}/config/redis.yml")
Resque.redis = resque_config[Rails.env]