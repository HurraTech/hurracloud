### Dev Environment Setup 

1. Checkout code

        git clone --recurse-submodules https://github.com/hurratech/hurracloud.git

2. Install dependencies

        # macOS
        brew install go vagrant virtualbox leveldb tmux protoc-gen-go protoc-gen-go-grpc

        # Linux (Fedora)
        dnf install leveldb leveldb-devel tmux protoc-gen-go protoc-gen-go-grpc

3. Install Air tool (allows hot reload of Golang app)

        curl -sSfL https://raw.githubusercontent.com/cosmtrek/air/master/install.sh | sh -s -- -b /usr/local/bin


3. Install node-modules (only needed first time or when pacakge.json has changed)

        cd src/samaa
        docker run -it -v $(pwd):/app node:14.8.0 bash
        cd /app && npm install
        exit


4. This will split the terminal windows for you and start all applications (you need to tmux for this, availabla via standard package managers) 

        ./start-all.sh

5. Access the UI at [http://localhost:8080/](http://localhost:8080)

### Option B: Start Components Individually

All Go components can be started manually using Go commands as shown below, or using Air tool, in each go submodule there is a config file `.air.toml` which can be used to run the app as follows:

        air -c .air.toml

The command above should work for all Go submodules. For non-Go submodules (such as Samaa), please see the following subsections.

#### 1. Samaa (UI)

1. Install node-modules

        cd src/samaa
        docker run -it -v $(pwd):/app node:14.8.0 bash
        npm install
        exit

2. Run Docker container

        docker compose up


#### 2. Jawhar (core)
1. Create data directory (one-time)

        cd src/jawhar
        mkdir data # first time

2. Start Application - two options:  

- Using Local Souq service (have to start Souq service - see below)

        go run cmd/jawhar/jawhar.go -S http://127.0.0.1:5060
        # Or simply use air (tool that auto-build and reload whenever Go source code change):
        air -c .air.toml


- Or using Production Souq (https://souq.hurracloud.io - currently down ):

        go run cmd/jawhar/jawhar.go 


#### 3. HAgent (agent)

1. Run application

        cd src/hagent
        sudo go run server.go # sudo is needed for Disk and other privileged operations to work

        # Or simply use air (tool that auto-build and reload whenever Go source code change):
        sudo air -c .air.toml


#### 4. Zahif (files indexer)
*Optional:* Needed for search and indexing functionalities

        cd src/zahif
        go run cmd/zahif/zahif.go

        # Or simply use air (tool that auto-build and reload whenever Go source code change):
        sudo air -c .air.toml


#### 5. Souq (App Store and Update service)
*Optional:* Needed for App Store functionality

        cd src/souq
        go run cmd/souq/souq.go

        # Or simply use air (tool that auto-build and reload whenever Go source code change):
        sudo air -c .air.toml
