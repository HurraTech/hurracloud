/*
 *
 * Copyright 2015 gRPC authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// Package main implements a simple gRPC server that demonstrates how to use gRPC-Go libraries
// to perform unary, client streaming, server streaming and full duplex RPCs.
//
// It implements the route guide service whose definition can be found in routeguide/route_guide.proto.
package main

import (
	"context"
    "syscall"
//	"encoding/json"
	"flag"
	"fmt"
//	"io"
//	"io/ioutil"
	"log"
//	"math"
	"net"
//	"sync"
//	"time"
	"os/exec"

	"google.golang.org/grpc"

	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/examples/data"

//	"github.com/golang/protobuf/proto"

	pb "./proto"
)

var (
	tls        = flag.Bool("tls", false, "Connection uses TLS if true, else plain TCP")
	certFile   = flag.String("cert_file", "", "The TLS cert file")
	keyFile    = flag.String("key_file", "", "The TLS key file")
	jsonDBFile = flag.String("json_db_file", "", "A json file containing a list of features")
	port       = flag.Int("port", 10000, "The server port")
	uid		   = flag.Int("uid", -1, "Run commands using this user ID")
)

type hurraAgentServer struct {
	pb.UnimplementedHurraAgentServer
}

// ExecCommand returns the feature at the given point.
func (s *hurraAgentServer) ExecCommand(ctx context.Context, command *pb.Command) (*pb.Result, error) {
	cmd := exec.Command("bash", "-c", command.Command)
    cmd.SysProcAttr = &syscall.SysProcAttr{}
	if (*uid != -1) {
       cmd.SysProcAttr.Credential = &syscall.Credential{Uid: uint32(*uid), Gid: uint32(*uid)}
    }
    out, err := cmd.CombinedOutput()
	exitCode := int32(0)
    if err != nil {
		out = []byte(err.Error())
        exitCode = 1
	}
    log.Printf("Command: %s. Output: %s", command.Command, out)
    result := &pb.Result{Message: string(out), ExitCode: exitCode}
    return result,nil
}

func newServer() *hurraAgentServer {
	s := &hurraAgentServer{}
	return s
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf("172.18.0.1:%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	var opts []grpc.ServerOption
	if *tls {
		if *certFile == "" {
			*certFile = data.Path("x509/server_cert.pem")
		}
		if *keyFile == "" {
			*keyFile = data.Path("x509/server_key.pem")
		}
		creds, err := credentials.NewServerTLSFromFile(*certFile, *keyFile)
		if err != nil {
			log.Fatalf("Failed to generate credentials %v", err)
		}
		opts = []grpc.ServerOption{grpc.Creds(creds)}
	}
	grpcServer := grpc.NewServer(opts...)
	pb.RegisterHurraAgentServer(grpcServer, newServer())
	grpcServer.Serve(lis)
}
