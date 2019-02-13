class DrivePartition < ApplicationRecord
  include ActsAsSourcable  
  acts_as_sourcable
  belongs_to :drive

  def mount()
    self.status = :mounting
    self.save()
    Resque.enqueue(Mounter, 'mount_partition', :partition_id => self.id)
  end

  def unmount()
    self.status = :unmounting
    self.save()
    Resque.enqueue(Mounter, 'unmount_partition', :partition_id => self.id)
  end

  def browse(requested_path=nil)
    path = "#{Settings.mounts_path}#{self.id}/#{requested_path}"
    { 
      contents: Dir.entries(path).map {|i|
          entry_path = "#{path}/#{i}"
          file_extension = File.extname(entry_path).downcase
          file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
          {
              name: i,
              type: FileTest.directory?(entry_path) ? "folder": file_extension,
              path: "#{self.id}/#{requested_path}#{i}",
              last_modified: File.mtime(entry_path),
              filesize: File.size(entry_path)
          }
      }.select{ |e| e[:name] != '.' && ( !requested_path.nil? || e[:name] != '..') }
       .sort{ |e1,e2| e1[:type] == "folder" ? -1 : 1 }
  }
  end

  def mount_path
    "#{Settings.mounts_path}#{self.id}"
  end

  def host_mount_path
    "#{ENV['HOST_MOUNT_PATH']}#{self.id}"
  end

  def drive_type
    self.drive.drive_type
  end

  def as_json(options={})
    super(options.merge!(methods: [:drive_type]))
  end

end
