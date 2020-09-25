# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: hurra_agent.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("hurra_agent.proto", :syntax => :proto3) do
    add_message "proto.ContainersRequest" do
      optional :name, :string, 1
      optional :context, :string, 2
      optional :spec, :string, 3
    end
    add_message "proto.ContainersResponse" do
    end
    add_message "proto.ExecInContainerRequest" do
      optional :name, :string, 1
      optional :context, :string, 2
      optional :spec, :string, 3
      optional :container_name, :string, 4
      optional :cmd, :string, 5
    end
    add_message "proto.ExecInContainerResponse" do
    end
    add_message "proto.LoadImageRequest" do
      optional :URL, :string, 1
    end
    add_message "proto.LoadImageResponse" do
    end
    add_message "proto.UnloadImageRequest" do
      optional :tag, :string, 1
    end
    add_message "proto.UnloadImageResponse" do
    end
    add_message "proto.MountDriveResponse" do
      repeated :errors, :string, 1
      optional :is_successful, :bool, 2
    end
    add_message "proto.MountDriveRequest" do
      optional :device_file, :string, 1
      optional :mount_point, :string, 2
    end
    add_message "proto.UnmountDriveRequest" do
      optional :device_file, :string, 1
    end
    add_message "proto.UnmountDriveResponse" do
      optional :error, :string, 1
      optional :is_successful, :bool, 2
    end
    add_message "proto.GetDrivesRequest" do
    end
    add_message "proto.GetDrivesResponse" do
      repeated :drives, :message, 1, "proto.Drive"
    end
    add_message "proto.Drive" do
      optional :name, :string, 1
      optional :device_file, :string, 2
      optional :size_bytes, :uint64, 3
      optional :is_removable, :bool, 4
      optional :type, :string, 5
      optional :serial_number, :string, 6
      optional :storage_controller, :string, 7
      repeated :partitions, :message, 8, "proto.Partition"
    end
    add_message "proto.Partition" do
      optional :name, :string, 1
      optional :device_file, :string, 2
      optional :size_bytes, :uint64, 3
      optional :available_bytes, :uint64, 4
      optional :filesystem, :string, 5
      optional :mount_point, :string, 6
      optional :label, :string, 7
      optional :is_read_only, :bool, 8
    end
    add_message "proto.Result" do
      optional :exitCode, :int32, 1
      optional :message, :string, 2
    end
    add_message "proto.Command" do
      optional :command, :string, 1
    end
  end
end

module Proto
  ContainersRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.ContainersRequest").msgclass
  ContainersResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.ContainersResponse").msgclass
  ExecInContainerRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.ExecInContainerRequest").msgclass
  ExecInContainerResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.ExecInContainerResponse").msgclass
  LoadImageRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.LoadImageRequest").msgclass
  LoadImageResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.LoadImageResponse").msgclass
  UnloadImageRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.UnloadImageRequest").msgclass
  UnloadImageResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.UnloadImageResponse").msgclass
  MountDriveResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.MountDriveResponse").msgclass
  MountDriveRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.MountDriveRequest").msgclass
  UnmountDriveRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.UnmountDriveRequest").msgclass
  UnmountDriveResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.UnmountDriveResponse").msgclass
  GetDrivesRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.GetDrivesRequest").msgclass
  GetDrivesResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.GetDrivesResponse").msgclass
  Drive = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.Drive").msgclass
  Partition = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.Partition").msgclass
  Result = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.Result").msgclass
  Command = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.Command").msgclass
end
