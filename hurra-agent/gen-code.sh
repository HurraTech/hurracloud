#!/bin/bash
protoc -I . hurra_agent.proto --go_out=plugins=grpc:./proto
grpc_tools_ruby_protoc -I . --ruby_out=../jawhar/app/lib --grpc_out=../jawhar/app/lib hurra_agent.proto
# bundle exec rake 'protobuf:compile[proto, "./ hurra_agent.proto", "../jawhar/app/lib/"]'
cp hurra_agent.proto ../jawhar/
