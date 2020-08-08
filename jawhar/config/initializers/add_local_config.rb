Settings.add_source!({host_mounts_path: ENV['HOST_MOUNTS_PATH']})
Settings.add_source!({skip_partitions: ENV['SKIP_PARTITIONS']})
Settings.add_source!({samaa_root_url: ENV['SAMAA_ROOT_URL']})
Settings.reload!
