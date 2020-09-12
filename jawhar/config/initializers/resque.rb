rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_RESQUE_ENV'] || 'development'
config_file = rails_root + '/config/resque.yml'

resque_config = YAML::load(ERB.new(IO.read(config_file)).result)
Resque.redis = Settings.redis

Resque.logger.level = Logger::DEBUG
Resque.logger = Logger.new(Rails.root.join('log', "#{Rails.env}_resque.log"))

Resque.after_fork do |job|
  if job.queue == "mounter"
    # Resque.logger.info("Initializing GRPC client for job #{job.inspect}")
    # $hurraAgent = ::Proto::HurraAgent::Stub.new("#{Settings.hurra_agent_server}:#{Settings.hurra_agent_port}}", :this_channel_is_insecure)
  end
end
