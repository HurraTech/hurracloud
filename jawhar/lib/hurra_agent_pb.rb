# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: hurra_agent.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("hurra_agent.proto", :syntax => :proto3) do
    add_message "proto.Result" do
      optional :exitCode, :int32, 1
      optional :message, :string, 2
    end
    add_message "proto.Command" do
      optional :command, :string, 3
    end
  end
end

module Proto
  Result = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.Result").msgclass
  Command = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("proto.Command").msgclass
end
