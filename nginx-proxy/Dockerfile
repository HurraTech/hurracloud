# Forego
FROM golang as build

WORKDIR /
RUN go get -u github.com/ddollar/forego
RUN go build github.com/ddollar/forego


# docker-gen amd64
FROM alpine:latest as dockergen-amd64
LABEL maintainer="Jason Wilder <mail@jasonwilder.com>"

RUN apk -U add openssl

ENV VERSION 0.7.4
ENV DOWNLOAD_URL https://github.com/jwilder/docker-gen/releases/download/$VERSION/docker-gen-alpine-linux-amd64-$VERSION.tar.gz
RUN wget -qO- $DOWNLOAD_URL | tar xvz -C /usr/local/bin

# docker-gen arm64
FROM alpine:latest as dockergen-armd64
LABEL maintainer="Jason Wilder <mail@jasonwilder.com>"

RUN apk -U add openssl

ENV VERSION 0.7.4
ENV DOWNLOAD_URL https://github.com/jwilder/docker-gen/releases/download/$VERSION/docker-gen-alpine-linux-armhf-$VERSION.tar.gz
RUN wget -qO- $DOWNLOAD_URL | tar xvz -C /usr/local/bin

#### Image
FROM nginx:1.17.8
LABEL maintainer="Jason Wilder mail@jasonwilder.com"

# Install wget and install/updates certificates
RUN apt-get update \
 && apt-get install -y -q --no-install-recommends \
    ca-certificates \
    wget \
 && apt-get clean \
 && rm -r /var/lib/apt/lists/*


# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Install Forego
COPY --from=build /forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

ENV DOCKER_GEN_VERSION 0.7.4

COPY --from dockergen-${TARGETARCH} /usr/local/bin/docker-gen /usr/local/bin/
COPY network_internal.conf /etc/nginx/

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
