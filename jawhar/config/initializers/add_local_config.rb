Settings.add_source!({host_mounts_path: ENV['HOST_MOUNTS_PATH']})
Settings.add_source!({skip_partitions: ENV['SKIP_PARTITIONS']})
Settings.add_source!({samaa_root_url: ENV['SAMAA_ROOT_URL']})
Settings.add_source!({host_app_store_path: ENV['HOST_APP_STORE_PATH']})
Settings.add_source!({host_uid_: ENV['HOST_UID']})
Settings.add_source!({hostname: ENV['HURRA_HOSTNAME']})
Settings.add_source!({redis: ENV['REDIS'] || "127.0.0.1:6379"})
Settings.add_source!({hurra_agent_server: ENV['HURRA_AGENT_SERVER'] || "127.0.0.1" })
Settings.add_source!({hurra_agent_port: ENV['HURRA_HOSTNAME']  || 10000 })
Settings.add_source!({es_endpoint: ENV['ES_ENDPOINT'] || "127.0.0.1:9200" })

Settings.reload!
