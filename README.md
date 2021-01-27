### Dev Environment Setup (macOS)

#### Pre-requisites

1. Checkout code

        git clone --recurse-submodules git@bitbucket.org:aimannajjar/hurracloud.git


2. Install dependencies

    ```
    brew install go vagrant virtualbox leveldb
    ```


#### Samaa (UI)

1. Install node-modules

    ```
    cd src/samaa
    docker run -it -v $(pwd):/app node:14.8.0 bash
    npm install
    exit
    ```

2. Run Docker container

    ```
    docker-compose up
    ```

#### Jawhar (core)
1. Create data directory (one-time)

    ```
    cd src/jawhar
    mkdir data # first time
    ```
2. Start Application: two options:  
2.1. Using Local Souq service (have to start Souq service - see below)

    ```
    go run cmd/jawhar/jawhar.go -S http://127.0.0.1:5060
    ```

    2.2. Or using Production Souq (https://souq.hurracloud.io - currently down ):

    ```
    go run cmd/jawhar/jawhar.go 
    ```

#### HAgent (agent)
1. Create Linux box

    ```
    cd vagrant
    vagrant up
    ```

2. Run application

    ```
    vagrant ssh
    go run server.go
    ```

#### Zahif (files indexer)
*Optional:* Needed for search and indexing functionalities
```
go run cmd/zahif/zahif.go
```

#### Souq (App Store service)
*Optional:* Needed for App Store functionality
```
go run cmd/souq/souq.go
```

### Access the UI at http://localhost:8080/