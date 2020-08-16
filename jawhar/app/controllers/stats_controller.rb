class StatsController < ApplicationController

  def stats
    cpu_load = `cut -f 1 -d " " /proc/loadavg`.chomp().to_f
    total_mem = `awk '/MemTotal/ { printf "%.3f", $2/1024/1024 }' /proc/meminfo`.chomp().to_f
    free_mem = `awk '/MemFree/ { printf "%.3f", $2/1024/1024 }' /proc/meminfo`.chomp().to_f
	disk_stats = `lsblk -o NAME -dpnlb -e7 | xargs iostat -d | egrep -v "Linux|Device|^$"`.split("\n").map do |line|
		fields = line.split(" ")
		{ name: fields[0],
		  reads_per_second: fields[2].to_f,
	      writes_per_second: fields[3].to_f,
          total_bytes_read: fields[4].to_f,
          total_bytes_written: fields[5].to_f
		}
	end
     total_disk_stats = {
       "reads_per_second": disk_stats.map{ |s| s[:reads_per_second]}.inject(0, &:+),
       "writes_per_second": disk_stats.map{ |s| s[:writes_per_second]}.inject(0, &:+),
       "total_bytes_read": disk_stats.map{ |s| s[:total_bytes_read]}.inject(0, &:+),
       "total_bytes_written":disk_stats.map{ |s| s[:total_bytes_written]}.inject(0, &:+)
  	}
    render json: {  cpu_load: cpu_load, total_memory: total_mem, free_memory: free_mem, disk_stats: total_disk_stats }
  end

end
