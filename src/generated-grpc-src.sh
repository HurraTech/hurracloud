#!/bin/bash

# 1- Agent Protocol
cd agent
protoc -I . hurra_agent.proto --go_out=plugins=grpc:./proto
protoc -I . hurra_agent.proto --go_out=plugins=grpc:../jawhar/internal/agent/proto

# 2- Zahif Protocol
cd ../zahif
protoc -I . zahif.proto --go_out=plugins=grpc:./internal/server/proto
protoc -I . zahif.proto --go_out=plugins=grpc:../jawhar/internal/zahif/proto/
