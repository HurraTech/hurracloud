grpc_root = File.join(Rails.application.config.root, "/lib/hurracloud-agent")
$LOAD_PATH.unshift(grpc_root)
Dir[File.join(grpc_root, "**/*.rb")].each do |file|
  require file
end

Rails.application.config.hurracloud_agent = ::Proto::HurraAgent::Stub.new("#{Settings.hurra_agent_server}:#{Settings.hurra_agent_port}}", :this_channel_is_insecure)