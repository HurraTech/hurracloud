#!/bin/bash

echo "Building Jawhar"
docker buildx build -f Jawhar.Dockerfile --platform linux/arm64,linux/amd64 -t aimannajjar/hurracloud:jawhar-v1 . --push

echo "Building Samaa"
docker buildx build -f Samaa.Dockerfile --platform linux/arm64,linux/amd64 -t aimannajjar/hurracloud:samaa-v1 . --push

echo "Building Syncthing"
docker buildx build -f ./docker-syncthing/Dockerfile --platform linux/arm64,linux/amd64 -t aimannajjar/hurracloud:syncthing ./docker-syncthing --push
