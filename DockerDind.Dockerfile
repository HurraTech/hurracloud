FROM docker:dind

ENV DOCKER_BUILDKIT=1
RUN wget https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64 -O buildx && \
    chmod +x buildx
RUN mkdir -p ~/.docker/cli-plugins
RUN mv ./buildx ~/.docker/cli-plugins/docker-buildx

